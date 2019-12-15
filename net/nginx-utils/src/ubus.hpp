#ifndef __NGINX_CREATE_LISTEN_H
#define __NGINX_CREATE_LISTEN_H

#include <vector>
#include <string>
#include <memory>
#include <mutex>
#include <cassert>
extern "C" {
#include <libubus.h>
}


typedef std::vector<std::string> strings;


static const strings _MATCH_ALL_KEYS_ = {"*"};


inline void append(strings & both) {}


template<class String, class ...Strings>
inline void append(strings & both, String key, Strings ...filter)
{
    both.push_back(std::move(key));
    append(both, std::move(filter)...);
}



class ubus_iterator {

    friend class ubus;

    friend class ubus_call;

private:

    const strings & keys;

    const size_t n;

    size_t i = 0;

    const blob_attr * pos;

    ubus_iterator * cur;

    const ubus_iterator * parent = NULL;

    size_t rem = 0;


    inline bool matches() const {
        return (keys[i]==_MATCH_ALL_KEYS_[0]
                || blobmsg_name(cur->pos)==keys[i]);
    }


    ubus_iterator(const blob_attr * msg = NULL,
            const strings & filter = _MATCH_ALL_KEYS_)
    : keys{filter}, n{keys.size()-1}, pos{msg}, cur{this}
    {
        if (pos!=NULL) {
            rem = blobmsg_data_len(pos);
            pos = (blob_attr *) blobmsg_data(pos);
            if (i!=n || !matches()) { ++*this; }
        }
    }


    ubus_iterator(const ubus_iterator * par)
    : keys{par->keys}, n{par->n}, pos{par->pos}, cur{this}, parent{par}
    {
        if (pos!=NULL) {
            rem = blobmsg_data_len(pos);
            pos = (blob_attr *) blobmsg_data(pos);
        }
    }


public:

    ubus_iterator(const ubus_iterator & rhs) = delete;


    ubus_iterator(ubus_iterator && rhs) = default;


    inline auto key() { return blobmsg_name(cur->pos); }


    inline auto value() { return blobmsg_data(cur->pos); }


    inline auto type() { return blob_id(cur->pos); }


    inline auto operator*() { return blobmsg_data(cur->pos); }


    inline auto operator!=(const ubus_iterator & rhs)
    { return (cur->rem!=rhs.cur->rem || cur->pos!=rhs.cur->pos); }


    ubus_iterator & operator++();

};


class ubus_call {

private:

    static ubus_context * ctx; // lazy initialization when needed.

    static std::mutex buffering;

    static blob_buf buf;

    const std::shared_ptr<const blob_attr> msg; // initialized by callback.

    const std::shared_ptr<const ubus_request> req; // initialized by callback.

    const strings keys;

    /* Cannot capture *this (the lambda would not be a ubus_data_handler_t).
     * Pass this as priv pointer when invoking and get it back here:
    */
    ubus_data_handler_t callback =
        [](ubus_request * req, int type, blob_attr * msg) -> void
    {
        if (!req) { return; }
        const ubus_call * obj = reinterpret_cast<ubus_call *>(req->priv);
        if (!obj) { return; }

        auto tmp_req = new ubus_request;
        memcpy(tmp_req, req, sizeof(ubus_request));

        typedef std::remove_const<decltype(obj->req)>::type obj_req_type;
        const_cast<obj_req_type &>(obj->req).reset(tmp_req);

        if (!msg) { return; }

        auto tmp_msg = blob_memdup(msg);
        if (!tmp_msg) { throw std::bad_alloc(); }

        typedef std::remove_const<decltype(obj->msg)>::type obj_msg_type;
        const_cast<obj_msg_type &>(obj->msg).reset(tmp_msg, free);
    };


    static void init_ctx() 
    {
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

    
    ubus_call(const std::shared_ptr<const blob_attr> & message,
              const std::shared_ptr<const ubus_request> & request,
              strings filter = _MATCH_ALL_KEYS_)
    : msg{message}, req{request}, keys{std::move(filter)} {}

    
public:

    ubus_call(const ubus_call &) = delete;


    ubus_call(ubus_call &&) = default;


    ubus_call(const char * path, const char * method="", const int timeout=500)
    {
        init_ctx();

        uint32_t id;
        int err = ubus_lookup_id(ctx, path, &id);

        if (!err) { // call
            buffering.lock();
            blob_buf_init(&buf, 0);
            err = ubus_invoke(ctx, id, method, buf.head, callback, this, timeout);
            buffering.unlock();
            //TODO async?
        }

        if (err) {
            std::string errmsg = "ubus::call error: cannot invoke";
            errmsg +=  " (" + std::to_string(err) + ") " + path + " " + method;
            throw std::runtime_error(errmsg.c_str());
        }
    }


    auto begin() { return ubus_iterator{msg.get(), keys}; }


    const auto end() {
        static ubus_iterator end{};
        return std::move(end);
    }


    template<class ...Strings>
    auto filter(Strings ...filter)
    {
        strings both{};
        if (keys!=_MATCH_ALL_KEYS_) { both = keys; }
        append(both, std::move(filter)...);
        return std::move(ubus_call{msg, req, std::move(both)});
    }


    ~ubus_call() = default;

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
    static void extractor(ubus_request * req, int type, blob_attr * msg);


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


    ubus(const std::shared_ptr<const blob_attr> & message,
         const std::shared_ptr<const ubus_request> & request,
         strings filter = _MATCH_ALL_KEYS_)
    : msg{message}, req{request}, keys{std::move(filter)} {}


public:

    ubus() : msg{NULL}, req{NULL}, keys{_MATCH_ALL_KEYS_} {}


    ubus(const ubus &) = delete;


    ubus(ubus &&) = default;


    auto begin() { return ubus_iterator{msg.get(), keys}; }


    const auto end() {
        static ubus_iterator end{};
        return std::move(end);
    }


    template<class ...Strings>
    auto filter(Strings ...filter)
    {
        strings both{};
        if (keys!=_MATCH_ALL_KEYS_) { both = keys; }
        append(both, std::move(filter)...);
        return std::move(ubus{msg, req, std::move(both)});
    }


    static std::string request_str(const ubus_request * req) {
        std::string ret{};
        ret += std::to_string(req->status_code) + "status_code ";
        ret += std::string(req->status_msg ? "+" : "-") + "status_msg ";
        ret += std::string(req->blocked ? "+" : "-") + "blocked ";
        ret += std::string(req->cancelled ? "+" : "-") + "cancelled ";
        ret += std::string(req->notify ? "+" : "-") + "notify ";
        ret += std::to_string(req->peer) + "peer ";
        ret += std::to_string(req->seq) + "seq ";
        ret += std::to_string(req->fd) + "fd ";
        ret += std::to_string((size_t)req->ctx) + "ctx ";
        if (req->priv) { ret += std::string((char *)req->priv) + "priv "; }
        return std::move(ret);
    }


    static auto call(const char * path,
                     const char * method="", const int timeout=500);

};



// ------------------------- implementation: ----------------------------------


ubus_context * ubus_call::ctx = NULL;


blob_buf ubus_call::buf;


std::mutex ubus_call::buffering;



ubus_context * ubus::ctx = NULL;


blob_buf ubus::buffer;


std::mutex ubus::buffering;


ubus_iterator & ubus_iterator::operator++()
{
    for(;;) {
        #ifndef NDEBUG
            std::cout<<std::string(i,'>')<<" look for "<<keys[i]<<" at ";
            std::cout<<cur->key()<<" : "<<(char*)cur->value()<<std::endl;
        #endif

        auto id = blob_id(cur->pos);
        if ( (id==BLOBMSG_TYPE_TABLE || id==BLOBMSG_TYPE_ARRAY)
                && i<n
                && matches()
                && blobmsg_data_len(cur->pos)>0 )
        { //immmerge:
            ++i;
            cur = new ubus_iterator{cur};
        } else {
            while (true) {
                cur->rem -= blob_pad_len(cur->pos);
                cur->pos = blob_next(cur->pos);
                auto len = blob_pad_len(cur->pos);

                if (cur->rem>0 && len<=cur->rem && len>=sizeof(blob_attr))
                { break; }

                //emerge:
                auto * tmp = const_cast<ubus_iterator *>(cur->parent);
                if (!tmp) {
                    cur->pos = NULL;
                    return *cur;
                }

                delete cur;
                cur = tmp;
                --i;
            }
        }
        if (i==n && matches()) { return *cur; }
    }
}


void ubus::extractor(ubus_request * req, int type, blob_attr * msg)
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
}


auto ubus::call(const char * path, const char * method, const int timeout)
{
    init_ctx();

    uint32_t id;
    int err = ubus_lookup_id(ctx, path, &id);

    if (err == 0) { // call
        ubus ret{};

        buffering.lock();
        blob_buf_init(&buffer, 0);
        // locking extractor internally:
        err = ubus_invoke(ctx, id, method, buffer.head,
                            extractor, NULL, timeout);
        buffering.unlock();

        extractor((ubus_request *)(&ret.req), // sic: change type and const!
                    __UBUS_MSG_LAST,
                    (blob_attr *)(&ret.msg)); // sic: change type and const!
        // unlocking extractor internally.

        #ifndef NDEBUG
            std::cout<<"ubus call "<<path<<" "<<method<<std::endl;
            std::cout<<" -> "<<request_str(ret.req.get())<<std::endl;
        #endif

        if (err==0) { return ret; }
    }
    // err!=0:
    std::string errmsg = "ubus::call error: cannot invoke ";
    errmsg = errmsg + path + " " + method + " (" + std::to_string(err) + ") ";
    throw std::runtime_error(errmsg.c_str());
}


#endif
