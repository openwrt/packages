
#ifndef __NGINX_CREATE_LISTEN_H
#define __NGINX_CREATE_LISTEN_H

#include <string>

#ifdef openwrt
#include <vector>
#include <memory>
#include <mutex>
#include <cassert>
extern "C" {
#include <libubus.h>
}
#endif


#ifdef openwrt


namespace ubus {



typedef std::vector<std::string> strings;



inline void append(strings & both) {}


template<class String, class ...Strings>
inline void append(strings & both, String key, Strings ...filter)
{
    both.push_back(std::move(key));
    append(both, std::move(filter)...);
}



static const strings _MATCH_ALL_KEYS_ = {"*"};



class iterator {
    friend class ubus;

private:
    const strings & keys;
    size_t i = 0;
    const blob_attr * pos;
    iterator * cur;
    const iterator * parent = NULL;
    size_t rem = 0;


    inline bool matches() const {
        return (keys[i]==_MATCH_ALL_KEYS_[0]
                || blobmsg_name(cur->pos)==keys[i]);
    }


    iterator(const blob_attr * msg = NULL,
            const strings & filter = _MATCH_ALL_KEYS_)
    : keys{filter}, pos{msg}, cur{this}
    {
        if (pos!=NULL) {
            rem = blobmsg_data_len(pos);
            pos = (blob_attr *) blobmsg_data(pos);
            if (i!=keys.size()-1 || !matches()) { ++*this; }
        }
    }


    iterator(const iterator * par)
    : keys{par->keys}, pos{par->pos}, cur{this}, parent{par}
    {
        if (pos!=NULL) {
            rem = blobmsg_data_len(pos);
            pos = (blob_attr *) blobmsg_data(pos);
        }
    }


public:

    iterator(const iterator & rhs) = delete;

    iterator(iterator && rhs) = default;

    inline auto key() { return blobmsg_name(cur->pos); }

    inline auto value() { return blobmsg_data(cur->pos); }

    inline auto type() { return blob_id(cur->pos); }

    inline auto operator*() { return blobmsg_data(cur->pos); }


    inline auto operator!=(const iterator & rhs)
    { return (cur->rem!=rhs.cur->rem || cur->pos!=rhs.cur->pos); }


    iterator & operator++()
    {
        for(;;) {
            #ifndef NDEBUG
                std::cout<<std::string(i,'>')<<" look for "<<keys[i]<<" at ";
                std::cout<<cur->key()<<" : "<<(char*)cur->value()<<std::endl;
            #endif

            auto id = blob_id(cur->pos);
            if ( (id==BLOBMSG_TYPE_TABLE || id==BLOBMSG_TYPE_ARRAY)
                 && i<keys.size()-1
                 && matches()
                 && blobmsg_data_len(cur->pos)>0 )
            { //immmerge:
                ++i;
                cur = new iterator{cur};
            } else {
                while (true) {
                    cur->rem -= blob_pad_len(cur->pos);
                    cur->pos = blob_next(cur->pos);
                    auto len = blob_pad_len(cur->pos);

                    if (cur->rem>0 && len<=cur->rem && len>=sizeof(blob_attr))
                    { break; }

                    //emerge:
                    auto * tmp = const_cast<iterator *>(cur->parent);
                    if (!tmp) {
                        cur->pos = NULL;
                        return *cur;
                    }

                    delete cur;
                    cur = tmp;
                    --i;
                }
            }
            if (i==keys.size()-1 && matches()) { return *cur; }
        }
    }

};



class ubus {

private:
    static ubus_context * ctx; // lazy initialization when needed.
    static std::mutex buffering;
    static blob_buf buffer;
    const std::shared_ptr<const blob_attr> msg; // initialized by extractor.
    const std::shared_ptr<const ubus_request> req; // initialized by extractor.
    const strings keys;


    /* Cannot capture *this (the lambda would not be a ubus_data_handler_t).
    *   ubus_data_handler_t extractor = // wrong type!
    *       [this](ubus_request * req, int type, blob_attr * msg) -> void
    * So we use the following static function with type ubus_data_handler_t
    * instead. As its signature is fixed, we use a workaround for writing to
    * members using type=__UBUS_MSG_LAST as flag. An extraction works as
    * follows: first give this function as callback to ubus for saving the
    * values, then get them back _immediately_ by calling it with (writable)
    * plain pointers to shared_ptrs and the invalid type __UBUS_MSG_LAST; we
    * must cast the pointers to match the signature:
    *   extractor((ubus_request *)&req, __UBUS_MSG_LAST, (blob_attr *)&msg);
    * Between saving and retrieving we lock a mutex for not mixing data:
    */
    static void extractor(ubus_request * req, int type, blob_attr * msg)
    {
        static std::mutex extracting;
        static std::shared_ptr<const ubus_request> saved_req;
        static std::shared_ptr<const blob_attr> saved_msg;
        if (type != __UBUS_MSG_LAST) {
            assert (!saved_msg && !saved_req);

            extracting.lock();

            if (req!=NULL) {
                auto tmp = new(std::nothrow) ubus_request;
                if (!tmp) {
                    extracting.unlock();
                    throw std::bad_alloc();
                }

                memcpy(tmp, req, sizeof(ubus_request));

                saved_req.reset(tmp);
            }

            if (msg!=NULL) {
//                 size_t len = blob_raw_len(msg);
//                 auto tmp = malloc(sizeof(blob_attr)+len);
//                 memcpy(tmp, msg, len);
                auto tmp = blob_memdup(msg);

                if (!tmp) {
                    extracting.unlock();
                    throw std::bad_alloc();
                }

                saved_msg.reset((blob_attr *)tmp, free);
            }

            return;
        } else if (req!=NULL && msg!=NULL) {
            auto * preq
                = reinterpret_cast<std::shared_ptr<const ubus_request> *>(req);
            auto * pmsg
                = reinterpret_cast<std::shared_ptr<const blob_attr> *>(msg);
            assert (*pmsg==NULL && *preq==NULL);

            *preq = std::move(saved_req);
            *pmsg = std::move(saved_msg);

            extracting.unlock();
            return;
        } else {
            throw std::runtime_error("ubus::extractor error: "
                                     "cannot write request/message");
        }
    };


    ubus(const std::shared_ptr<const blob_attr> & message,
         const std::shared_ptr<const ubus_request> & request,
         strings filter = _MATCH_ALL_KEYS_)
    : msg{message}, req{request}, keys{std::move(filter)} {}


    static void init_ctx() {
        static std::unique_ptr<ubus_context, decltype(&ubus_free)>
            lazy_ctx{ubus_connect(NULL), ubus_free};

        if (!lazy_ctx) { // it could be available on a later call:
            static std::mutex connecting;
            connecting.lock();
            if (!lazy_ctx) { lazy_ctx.reset(ubus_connect(NULL)); }
            connecting.unlock();
            if (!lazy_ctx) {
                throw std::runtime_error("ubus error: cannot connect context");
            }
        }

        ctx = lazy_ctx.get();
    }


public:

    ubus(const ubus &) = delete;

    ubus(ubus &&) = default;

    ubus() : msg{NULL}, req{NULL}, keys{_MATCH_ALL_KEYS_} {}


    template<class ...Strings>
    auto filter(Strings ...filter)
    {
        strings both{};
        if (keys!=_MATCH_ALL_KEYS_) { both = keys; }
        append(both, std::move(filter)...);
        return std::move(ubus{msg, req, std::move(both)});
    }


    auto begin() { return iterator{msg.get(), keys}; }


    const auto end() {
        static iterator end{};
        return std::move(end);
    }


    std::string req_str() {
        std::string ret{};
        ret += std::to_string(req->status_code) + "status_code ";
        ret += (req->status_msg ? '+' : '-') + "status_msg ";
        ret += (req->blocked ? '+' : '-') + "blocked ";
        ret += (req->cancelled ? '+' : '-') + "cancelled ";
        ret += (req->notify ? '+' : '-') + "notify ";
        ret += std::to_string(req->peer) + "peer ";
        ret += std::to_string(req->seq) + "seq ";
        ret += std::to_string(req->fd) + "fd ";
        ret += std::to_string((size_t)req->ctx) + "ctx ";
        if (req->priv) { ret += std::string((char *)req->priv) + "priv "; }
        return std::move(ret);
    }


    static auto call(const char * path, const char * method="")
    {
        init_ctx();

        uint32_t id;
        int err = ubus_lookup_id(ctx, path, &id);

        if (err == 0) { // call
            int timeout = 200;

            buffering.lock();
            blob_buf_init(&buffer, 0);
            err = ubus_invoke(ctx, id, method, buffer.head,
                              extractor, NULL, timeout);
            buffering.unlock();

            ubus ret{};
            // change the type for writing req and msg:
            extractor((ubus_request *)(&ret.req),
                        __UBUS_MSG_LAST,
                        (blob_attr *)(&ret.msg));
            #ifndef NDEBUG
                std::cout<<"ubus call "<<path<<" "<<method;
                std::cout<<" -> "<<ret.req_str()<<std::endl;
            #endif
            if (err==0) { return ret; }
        }
        // err!=0:
        std::string errmsg = "ubus::call error: cannot invoke ";
        errmsg = errmsg + path + " " + method + " (" + std::to_string(err) + ") ";
        throw std::runtime_error(errmsg.c_str());
    }


};

ubus_context * ubus::ctx = NULL;

blob_buf ubus::buffer;

std::mutex ubus::buffering;



auto call(const char * path, const char * method="");
auto call(const char * path, const char * method)
{
    return ubus::call(path, method);
}



} // namespace ubus;



#endif


#endif
