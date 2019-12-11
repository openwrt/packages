
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
                std::cout<<std::string(i,'>')<<" look for "<<keys[i]<<" (";
                std::cout<<cur->key()<<" : "<<(char*)cur->value()<<")"<<std::endl;
            #endif

            auto id = blob_id(cur->pos);
            if ( (id==BLOBMSG_TYPE_TABLE || id==BLOBMSG_TYPE_ARRAY)
                 && i<keys.size()-1 && matches() && blobmsg_data_len(cur->pos)>0 )
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
                    if (tmp==NULL) {
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
    friend auto call(const char * path, const char * method);

private:
    ubus_context * ctx = ubus_connect(NULL);

    const std::shared_ptr<const blob_attr> msg;
    const std::shared_ptr<const ubus_request> req;
    const strings keys;

    /* Cannot capture *this (the lambda would not be a ubus_data_handler_t).
    * The signature of this function is fixed, workaround for writing to
    * members by casting the pointers (use type=__UBUS_MSG_LAST as flag).
    * Give this as callback to ubus for saving the values and get them back
    * immediately by calling it with writable double pointers that are casted:
    * extractor((ubus_request *)&&req, __UBUS_MSG_LAST, (blob_attr *)&&msg);
    * We lock a mutex between saving and retrieving for not mixing the data.
    */
    ubus_data_handler_t extractor =
        [](ubus_request * req, int type, blob_attr * msg) -> void
    {
        static std::mutex extracting;
        static std::shared_ptr<const ubus_request> saved_req;
        static std::shared_ptr<const blob_attr> saved_msg;
        if (type != __UBUS_MSG_LAST) {
            assert (!saved_msg && !saved_req);

            extracting.lock();

            if (req!=NULL) {
                auto tmp = new ubus_request;
                memcpy(tmp, req, sizeof(ubus_request));

                saved_req.reset(tmp);
            }

            if (msg!=NULL) {
                size_t len = blob_raw_len(msg);

                auto tmp = malloc(sizeof(blob_attr)+len);
                memcpy(tmp, msg, len);

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

    ubus(std::shared_ptr<const blob_attr> message = NULL,
        std::shared_ptr<const ubus_request> request = NULL,
        strings filter = _MATCH_ALL_KEYS_)
    : msg{std::move(message)}, req{std::move(request)}, keys{std::move(filter)}
    {}

    const static iterator iterator_end;

public:

    template<class ...Strings>
    auto filter(Strings ...filter)
    {
        strings both;
        if (keys!=_MATCH_ALL_KEYS_) { both = keys; }
        append(both, std::move(filter)...);
        return ubus{msg, req, std::move(both)};
    }

    auto begin() { return iterator{msg.get(), keys}; }

    auto end() { return iterator_end; }
};

const iterator ubus::iterator_end{};


auto call(const char * path, const char * method="")
{
    ubus ret;

    uint32_t id;
    int err = ubus_lookup_id(ret.ctx, path, &id);

    if (err == 0) { // call
        static blob_buf req;
        blob_buf_init(&req, 0);

        err = ubus_invoke(ret.ctx, id, method, req.head,
                          ret.extractor, NULL, 200);

        if (err==0) { // change the type for writing req and msg:
            ret.extractor((ubus_request *)(&ret.req),
                          __UBUS_MSG_LAST,
                          (blob_attr *)(&ret.msg));
        }
    }

    if (err != 0) {
        std::string errmsg = "ubus::call error: " + std::to_string(err)
                        + " cannot invoke " + path + " " + method;
        throw std::runtime_error(errmsg.c_str());
    }

    return ret;
}


}


#endif


#endif
