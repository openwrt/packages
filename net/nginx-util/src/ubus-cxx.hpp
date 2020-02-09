#ifndef _UBUS_CXX_HPP
#define _UBUS_CXX_HPP

extern "C" { //TODO(pst): remove when in upstream
#include <libubus.h>
}
#include <cassert>
#include <memory>
#include <mutex>
#include <string>
#include <utility>
#include <vector>
#ifndef NDEBUG
#include <iostream>
#endif


// // example for checking if there is a key:
// if (ubus::call("service", "list", 1000).filter("cron")) {
//     std::cout<<"Cron is active (with or without instances) "<<std::endl;
// }

// // example for getting values:
// auto lan_status = ubus::call("network.interface.lan", "status");
// for (auto x : lan_status.filter("ipv6-address", "", "address")) {
//     std::cout<<"["<<blobmsg_get_string(x)<<"] ";
// }
// for (auto x : lan_status.filter("ipv4-address", "").filter("address")) {
//     std::cout<<blobmsg_get_string(x)<<" ";
// }
// std::cout<<std::endl;

// // example for exploring:
// ubus::strings keys{"ipv4-address", "", ""};
// for (auto x : ubus::call("network.interface.lan", "status").filter(keys)) {
//     std::cout<<blobmsg_name(x)<<": ";
//     switch (blob_id(x)) {
//         case BLOBMSG_TYPE_UNSPEC: std::cout<<"[unspecified]"; break;
//         case BLOBMSG_TYPE_ARRAY: std::cout<<"[array]"; break;
//         case BLOBMSG_TYPE_TABLE: std::cout<<"[table]"; break;
//         case BLOBMSG_TYPE_STRING: std::cout<<blobmsg_get_string(x); break;
//         case BLOBMSG_TYPE_INT64: std::cout<<blobmsg_get_u64(x); break;
//         case BLOBMSG_TYPE_INT32: std::cout<<blobmsg_get_u32(x); break;
//         case BLOBMSG_TYPE_INT16: std::cout<<blobmsg_get_u16(x); break;
//         case BLOBMSG_TYPE_BOOL: std::cout<<blobmsg_get_bool(x); break;
//         case BLOBMSG_TYPE_DOUBLE: std::cout<<blobmsg_get_double(x); break;
//         default: std::cout<<"[unknown]";
//     }
//     std::cout<<std::endl;
// }

// // example for recursive exploring (output like from the original ubus call)
// const auto explore = [](auto message) -> void
// {
//     auto end = message.end();
//     auto explore_internal =
//         [&end](auto & explore_ref, auto it, size_t depth=1) -> void
//     {
//         std::cout<<std::endl;
//         bool first = true;
//         for (; it!=end; ++it) {
//             auto * attr = *it;
//             if (first) { first = false; }
//             else { std::cout<<",\n"; }
//             std::cout<<std::string(depth, '\t');
//             std::string name = blobmsg_name(attr);
//             if (name != "") {  std::cout<<"\""<<name<<"\": "; }
//             switch (blob_id(attr)) {
//                 case BLOBMSG_TYPE_UNSPEC: std::cout<<"(unspecified)"; break;
//                 case BLOBMSG_TYPE_ARRAY:
//                     std::cout<<"[";
//                     explore_ref(explore_ref, ubus::iterator{attr}, depth+1);
//                     std::cout<<"\n"<<std::string(depth, '\t')<<"]";
//                     break;
//                 case BLOBMSG_TYPE_TABLE:
//                     std::cout<<"{";
//                     explore_ref(explore_ref, ubus::iterator{attr}, depth+1);
//                     std::cout<<"\n"<<std::string(depth, '\t')<<"}";
//                     break;
//                 case BLOBMSG_TYPE_STRING:
//                     std::cout<<"\""<<blobmsg_get_string(attr)<<"\"";
//                     break;
//                 case BLOBMSG_TYPE_INT64:
//                     std::cout<<blobmsg_get_u64(attr);
//                     break;
//                 case BLOBMSG_TYPE_INT32:
//                     std::cout<<blobmsg_get_u32(attr);
//                     break;
//                 case BLOBMSG_TYPE_INT16:
//                     std::cout<<blobmsg_get_u16(attr);
//                     break;
//                 case BLOBMSG_TYPE_BOOL:
//                     std::cout<<(blobmsg_get_bool(attr) ? "true" : "false");
//                     break;
//                 case BLOBMSG_TYPE_DOUBLE:
//                     std::cout<<blobmsg_get_double(attr);
//                     break;
//                 default: std::cout<<"(unknown)"; break;
//             }
//         }
//     };
//     std::cout<<"{";
//     explore_internal(explore_internal, message.begin());
//     std::cout<<"\n}"<<std::endl;
// };
// explore(ubus::call("network.interface.lan", "status"));



namespace ubus {

using msg_ptr = std::shared_ptr<const blob_attr>;

using strings = std::vector<std::string>;


inline auto concat(strings dest) { return dest; }


template<class ...Strings>
inline auto concat(strings dest, strings src, Strings ...more)
{
    dest.reserve(dest.size() + src.size());
    dest.insert(std::end(dest), std::make_move_iterator(std::begin(src)),
                std::make_move_iterator(std::end(src)));
    return concat(std::move(dest), std::move(more)...);
}


template<class S, class ...Strings>
inline auto concat(strings dest, S src, Strings ...more)
{
    dest.push_back(std::move(src));
    return concat(std::move(dest), std::move(more)...);
}



class iterator {

private:

    const strings & keys;

    const size_t n = 0;

    size_t i = 0;

    const blob_attr * pos = nullptr;

    std::unique_ptr<iterator> cur{};

    iterator * parent = nullptr;

    size_t rem = 0;


    [[nodiscard]] inline auto matches() const -> bool
    {
        return (keys[i].empty() || blobmsg_name(cur->pos)==keys[i]);
    }


    explicit iterator(iterator * par)
    : keys{par->keys}, n{par->n}, pos{par->pos}, cur{this}, parent{par}
    {
        if (pos!=nullptr) {
            rem = blobmsg_data_len(pos);
            pos = static_cast<blob_attr *>(blobmsg_data(pos));
        }
    }


public:

    explicit iterator(const blob_attr * msg, const strings & filter={""})
    : keys{filter}, n{keys.size()-1}, pos{msg}, cur{this}
    {
        if (pos!=nullptr) {
            rem = blobmsg_data_len(pos);
            pos = static_cast<blob_attr *>(blobmsg_data(pos));

            if (rem==0) { pos = nullptr; }
            else if (i!=n || !matches()) { ++*this; }
        }
    }


    inline iterator(iterator &&) = default;


    inline iterator(const iterator &) = delete;


    inline auto operator=(const iterator &) -> iterator & = delete;


    inline auto operator=(iterator &&) -> iterator & = delete;


    inline auto operator*() { return cur->pos; }


    inline auto operator!=(const iterator & rhs)
    { return (cur->rem!=rhs.cur->rem || cur->pos!=rhs.cur->pos); }


    auto operator++() -> iterator &;


    inline ~iterator() { if (cur.get()==this) { static_cast<void>(cur.release()); } }

};



class message {

private:

    const msg_ptr msg{}; // initialized by callback.

    const strings keys{};


public:

    inline explicit message(msg_ptr  message, strings filter={""})
    : msg{std::move(message)}, keys{std::move(filter)} {}


    inline message(message &&) = default;


    inline message(const message &) = delete;


    inline auto operator=(message &&) -> message & = delete;


    inline auto operator=(const message &) -> message & = delete;


    [[nodiscard]] inline auto begin() const -> iterator
    { return iterator{msg.get(), keys}; }


    [[nodiscard]] inline auto end() const -> iterator
    { return iterator{nullptr, keys}; }


    inline explicit operator bool() const { return begin()!=end(); }


    template<class ...Strings>
    auto filter(Strings ...filter)
    {
        strings both{};
        if (keys.size()!=1 || !keys[0].empty()) { both = keys; }
        both = concat(std::move(both), std::move(filter)...);
        return std::move(message{msg, std::move(both)});
    }


    inline ~message() = default;

};



class ubus {

private:

    static std::mutex buffering;


public:

    inline ubus() = delete;


    inline ubus(ubus &&) = delete;


    inline ubus(const ubus &) = delete;


    inline auto operator=(ubus &&) -> auto && = delete;


    inline auto operator=(const ubus &) -> auto & = delete;


    static auto get_context() -> ubus_context *
    {
        static auto ubus_freeing = [] (ubus_context * ctx) { ubus_free(ctx); };
        static std::unique_ptr<ubus_context, decltype(ubus_freeing)>
            lazy_ctx{ubus_connect(nullptr), ubus_freeing};

        if (!lazy_ctx) { // it could be available on a later call:
            static std::mutex connecting;

            connecting.lock();
            if (!lazy_ctx) { lazy_ctx.reset(ubus_connect(nullptr)); }
            connecting.unlock();

            if (!lazy_ctx) {
                throw std::runtime_error("ubus error: cannot connect context");
            }
        }

        return lazy_ctx.get();
    }


    static auto lock_and_get_shared_blob_buf() -> blob_buf *
    {
        static blob_buf buf;

        static auto blob_buf_freeing = [] (blob_buf * b) { blob_buf_free(b); };
        static std::unique_ptr<blob_buf, decltype(blob_buf_freeing)>
                created_to_free_on_the_end_of_life{&buf, blob_buf_freeing};

        buffering.lock();
        blob_buf_init(&buf, 0);
        return &buf;
    }


    static void unlock_shared_blob_buf() { buffering.unlock(); }


    inline ~ubus() = delete;

};


auto call(const char * path, const char * method="", int timeout=500);



// ------------------------- implementation: ----------------------------------


std::mutex ubus::buffering;


inline auto iterator::operator++() -> iterator &
{
    for(;;) {
        #ifndef NDEBUG
            std::cout<<std::string(i,'>')<<" look for "<<keys[i]<<" at ";
            std::cout<<blobmsg_name(cur->pos)<<std::endl;
        #endif

        auto id = blob_id(cur->pos);
        if ( (id==BLOBMSG_TYPE_TABLE || id==BLOBMSG_TYPE_ARRAY)
                && i<n
                && matches()
                && blobmsg_data_len(cur->pos)>0 )
        { //immmerge:
            ++i;

            auto tmp = cur.release();
            cur = std::unique_ptr<iterator>{new iterator(tmp)};

        } else {
            while (true) {
                cur->rem -= blob_pad_len(cur->pos);
                cur->pos = blob_next(cur->pos);
                auto len = blob_pad_len(cur->pos);

                if (cur->rem>0 && len<=cur->rem && len>=sizeof(blob_attr))
                { break; }

                //emerge:
                auto tmp = cur->parent;

                if (tmp == nullptr) {
                    cur->pos = nullptr;
                    return *cur;
                }

                cur.reset(tmp);

                --i;
            }
        }
        if (i==n && matches()) { return *cur; }
    }
}


inline auto call(const char * path, const char * method, const int timeout)
{
    auto ctx = ubus::get_context();

    uint32_t id;
    int err = ubus_lookup_id(ctx, path, &id);

    if (err==0) { // call
        ubus_request req{};

        auto buf = ubus::lock_and_get_shared_blob_buf();
        err = ubus_invoke_async(ctx, id, method, buf->head, &req);
        ubus::unlock_shared_blob_buf();

        if (err==0) {

            msg_ptr msg;

            /* Cannot capture anything (msg), the lambda would be another type.
            * Pass a location where to save the message as priv pointer when
            * invoking and get it back here:
            */
            req.priv = &msg;

            req.data_cb = [](ubus_request * req, int /*type*/, blob_attr * msg)
            {
                if (req==nullptr || msg==nullptr) { return; }

                auto saved = static_cast<msg_ptr *>(req->priv);
                if (saved==nullptr || *saved) { return; }

                saved->reset(blob_memdup(msg), free);
                if (!*saved) { throw std::bad_alloc(); }
            };

            err = ubus_complete_request(ctx, &req, timeout);

            if (err==0) { return message{msg}; }
        }
    }

    std::string errmsg = "ubus::call error: cannot invoke";
    errmsg +=  " (" + std::to_string(err) + ") " + path + " " + method;
    throw std::runtime_error(errmsg.c_str());
}


} // namespace ubus


#endif
