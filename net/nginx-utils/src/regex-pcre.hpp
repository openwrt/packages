// implementing *some* <regex> functions using pcre for performance:

#ifndef __REGEXP_PCRE_HPP
#define __REGEXP_PCRE_HPP

#include <pcre.h>
#include <string>


namespace std {


namespace regex_constants {
  enum error_type
    {
      _enum_error_collate,
      _enum_error_ctype,
      _enum_error_escape,
      _enum_error_backref,
      _enum_error_brack,
      _enum_error_paren,
      _enum_error_brace,
      _enum_error_badbrace,
      _enum_error_range,
      _enum_error_space,
      _enum_error_badrepeat,
      _enum_error_complexity,
      _enum_error_stack,
      _enum_error_last
    };
    static const error_type error_collate(_enum_error_collate);
    static const error_type error_ctype(_enum_error_ctype);
    static const error_type error_escape(_enum_error_escape);
    static const error_type error_backref(_enum_error_backref);
    static const error_type error_brack(_enum_error_brack);
    static const error_type error_paren(_enum_error_paren);
    static const error_type error_brace(_enum_error_brace);
    static const error_type error_badbrace(_enum_error_badbrace);
    static const error_type error_range(_enum_error_range);
    static const error_type error_space(_enum_error_space);
    static const error_type error_badrepeat(_enum_error_badrepeat);
    static const error_type error_complexity(_enum_error_complexity);
    static const error_type error_stack(_enum_error_stack);
}



class regex_error : public runtime_error {

protected:

    regex_constants::error_type errcode;


public:

    explicit regex_error(regex_constants::error_type code,
                         const char * what="regex error")
    : runtime_error(what), errcode(code)
    { }


    regex_constants::error_type code() const { return errcode; }

};



class regex {

private:

    int errcode;

    const char * errptr;

    int erroffset;

    pcre * const re;

    static const regex_constants::error_type pcre_errcode2regex_errcode[86];


public:

    regex(const string & str)
    : re{ pcre_compile2(str.c_str(), 0, &errcode, &errptr, &erroffset, NULL) }
    {
        if (re==NULL) {
            string what = (string)"regex error: " + errptr + '\n';
            what += "    '" + str + "'\n";
            what += string(erroffset+5, ' ') + '^';

            throw regex_error(pcre_errcode2regex_errcode[errcode],
                              what.c_str());
        }
    }


    ~regex() { if (re) { pcre_free(re); } }


    inline const pcre * operator()() const { return re; }

};



class smatch {

    friend auto regex_search(const string::const_iterator begin,
                             const string::const_iterator end,
                             smatch & match,
                             const regex & rgx);


private:

    string::const_iterator begin;

    string::const_iterator end;

    int * vec = NULL;

    int n = 0;

    size_t sz = 0;


public:

    smatch() = default;


    inline auto position(int i=0) const {
        return (i<0 || i>=n) ? string::npos : vec[2*i];
    }


    inline auto length(int i=0) const {
        return (i<0 || i>=n) ? 0 : vec[2*i+1] - vec[2*i];
    }


    string str(int i=0) const { // should we throw errors?
        if (i<0 || i>=n) { return ""; }
        int x = vec[2*i];
        if (x<0) { return ""; }
        int y = vec[2*i+1];
        return move(string{begin + x, begin + y});
    }


    auto format(const string & str) const;


    size_t size() const { return n; }


    inline auto empty() const { return n<0; }


    inline auto ready() const { return vec!=NULL; }


    ~smatch() { if (vec) { delete [] vec; } }

};


inline auto regex_search(const string & subj, const regex & rgx);


auto regex_replace(const string & subj,
                          const regex & rgx,
                          const string & insert);


inline auto regex_search(const string & subj, smatch & match, const regex & rgx);


auto regex_search(const string::const_iterator begin,
                  const string::const_iterator end,
                  smatch & match,
                  const regex & rgx);



// ------------------------- implementation: ----------------------------------


inline auto regex_search(const string & subj, const regex & rgx)
{
    int n = pcre_exec(rgx(), NULL, subj.c_str(), subj.length(), 0, 0, NULL, 0);
    return n>=0;
}


auto regex_search(const string::const_iterator begin,
                  const string::const_iterator end,
                  smatch & match,
                  const regex & rgx)
{
    if (rgx()==NULL) {
        //TODO
    } else {
        size_t sz = 0;
        pcre_fullinfo(rgx(), NULL, PCRE_INFO_CAPTURECOUNT, &sz);
        sz = 3*(sz + 1);

        if (sz > match.sz) {
            match.sz = 0;
            if (match.vec) { delete [] match.vec; }
            match.vec = new int[sz];
            match.sz = sz;
        }

        const char * subj = &*begin;
        size_t len = &*end - subj;

        match.begin = move(begin);
        match.end = move(end);

        match.n = pcre_exec(rgx(), NULL, subj, len, 0, 0, match.vec, sz);

        if (match.n<0) { return false; }
        if (match.n==0) { match.n = sz/3; }
    }
    return true;
}


inline auto regex_search(const string & subj, smatch & match, const regex & rgx)
{
    return regex_search(subj.begin(), subj.end(), match, rgx);
}


auto smatch::format(const string & fmt) const {
    string ret = "";
    size_t index = 0;

    size_t pos;
    while ((pos=fmt.find('$', index)) != string::npos) {
        ret.append(fmt, index, pos-index);
        index = pos + 1;

        char chr = fmt[index++];
        int n = 0;
        switch(chr) {

            case '&': // match
                ret += this->str(0);
                break;

            case '`': // prefix
                ret.append(begin, begin+vec[0]);
                break;

            case '\'': // suffix
                ret.append(begin+vec[1], end);
                break;

            default: // number => submatch
                while (isdigit(chr)) {
                    n = 10*n + chr - '0';
                    chr = fmt[index++];
                }

                ret += n>0 ? str(n) : string{"$"};

                [[fallthrough]];

            case '$': // escaped
                ret += chr;
        }
    }
    ret.append(fmt, index);
    return move(ret);
}


auto regex_replace(const string & subj,
                          const regex & rgx,
                          const string & insert)
{
    string ret = "";
    auto pos = subj.begin();

    for (smatch match;
         regex_search(pos, subj.end(), match, rgx);
         pos += match.position(0) + match.length(0))
    {
        ret.append(pos, pos + match.position(0));
        ret.append(match.format(insert));
    }

    ret.append(pos, subj.end());
    return move(ret);
}



// ------------ There is only the translation table below : -------------------


const regex_constants::error_type regex::pcre_errcode2regex_errcode[86] = {
    //   0  no error
    regex_constants::error_type::_enum_error_last,
    //   1  \ at end of pattern
    regex_constants::error_escape,
    //   2  \c at end of pattern
    regex_constants::error_escape,
    //   3  unrecognized character follows \ .
    regex_constants::error_escape,
    //   4  numbers out of order in {} quantifier
    regex_constants::error_badbrace,
    //   5  number too big in {} quantifier
    regex_constants::error_badbrace,
    //   6  missing terminating  for character class
    regex_constants::error_brack,
    //   7  invalid escape sequence in character class
    regex_constants::error_escape,
    //   8  range out of order in character class
    regex_constants::error_range,
    //   9  nothing to repeat
    regex_constants::error_badrepeat,
    //  10  [this code is not in use
    regex_constants::error_type::_enum_error_last,
    //  11  internal error: unexpected repeat
    regex_constants::error_badrepeat,
    //  12  unrecognized character after (? or (?-
    regex_constants::error_backref,
    //  13  POSIX named classes are supported only within a class
    regex_constants::error_range,
    //  14  missing )
    regex_constants::error_paren,
    //  15  reference to non-existent subpattern
    regex_constants::error_backref,
    //  16  erroffset passed as NULL
    regex_constants::error_type::_enum_error_last,
    //  17  unknown option bit(s) set
    regex_constants::error_type::_enum_error_last,
    //  18  missing ) after comment
    regex_constants::error_paren,
    //  19  [this code is not in use
    regex_constants::error_type::_enum_error_last,
    //  20  regular expression is too large
    regex_constants::error_space,
    //  21  failed to get memory
    regex_constants::error_stack,
    //  22  unmatched parentheses
    regex_constants::error_paren,
    //  23  internal error: code overflow
    regex_constants::error_stack,
    //  24  unrecognized character after (?<
    regex_constants::error_backref,
    //  25  lookbehind assertion is not fixed length
    regex_constants::error_backref,
    //  26  malformed number or name after (?(
    regex_constants::error_backref,
    //  27  conditional group contains more than two branches
    regex_constants::error_backref,
    //  28  assertion expected after (?(
    regex_constants::error_backref,
    //  29  (?R or (?[+-digits must be followed by )
    regex_constants::error_backref,
    //  30  unknown POSIX class name
    regex_constants::error_ctype,
    //  31  POSIX collating elements are not supported
    regex_constants::error_collate,
    //  32  this version of PCRE is compiled without UTF support
    regex_constants::error_collate,
    //  33  [this code is not in use
    regex_constants::error_type::_enum_error_last,
    //  34  character value in \x{} or \o{} is too large
    regex_constants::error_escape,
    //  35  invalid condition (?(0)
    regex_constants::error_backref,
    //  36  \C not allowed in lookbehind assertion
    regex_constants::error_escape,
    //  37  PCRE does not support \L, \l, \N{name}, \U, or \u
    regex_constants::error_escape,
    //  38  number after (?C is > 255
    regex_constants::error_backref,
    //  39  closing ) for (?C expected
    regex_constants::error_paren,
    //  40  recursive call could loop indefinitely
    regex_constants::error_complexity,
    //  41  unrecognized character after (?P
    regex_constants::error_backref,
    //  42  syntax error in subpattern name (missing terminator)
    regex_constants::error_paren,
    //  43  two named subpatterns have the same name
    regex_constants::error_backref,
    //  44  invalid UTF-8 string (specifically UTF-8)
    regex_constants::error_collate,
    //  45  support for \P, \p, and \X has not been compiled
    regex_constants::error_escape,
    //  46  malformed \P or \p sequence
    regex_constants::error_escape,
    //  47  unknown property name after \P or \p
    regex_constants::error_escape,
    //  48  subpattern name is too long (maximum 32 characters)
    regex_constants::error_backref,
    //  49  too many named subpatterns (maximum 10000)
    regex_constants::error_complexity,
    //  50  [this code is not in use
    regex_constants::error_type::_enum_error_last,
    //  51  octal value is greater than \377 in 8-bit non-UTF-8 mode
    regex_constants::error_escape,
    //  52  internal error: overran compiling workspace
    regex_constants::error_type::_enum_error_last,
    //  53  internal error: previously-checked referenced subpattern not found
    regex_constants::error_type::_enum_error_last,
    //  54  DEFINE group contains more than one branch
    regex_constants::error_backref,
    //  55  repeating a DEFINE group is not allowed
    regex_constants::error_backref,
    //  56  inconsistent NEWLINE options
    regex_constants::error_escape,
    //  57  \g is not followed by a braced, angle-bracketed, or quoted name/number or by a plain number
    regex_constants::error_backref,
    //  58  a numbered reference must not be zero
    regex_constants::error_backref,
    //  59  an argument is not allowed for (*ACCEPT), (*FAIL), or (*COMMIT)
    regex_constants::error_complexity,
    //  60  (*VERB) not recognized or malformed
    regex_constants::error_complexity,
    //  61  number is too big
    regex_constants::error_complexity,
    //  62  subpattern name expected
    regex_constants::error_backref,
    //  63  digit expected after (?+
    regex_constants::error_backref,
    //  64   is an invalid data character in JavaScript compatibility mode
    regex_constants::error_escape,
    //  65  different names for subpatterns of the same number are not allowed
    regex_constants::error_backref,
    //  66  (*MARK) must have an argument
    regex_constants::error_complexity,
    //  67  this version of PCRE is not compiled with Unicode property support
    regex_constants::error_collate,
    //  68  \c must be followed by an ASCII character
    regex_constants::error_escape,
    //  69  \k is not followed by a braced, angle-bracketed, or quoted name
    regex_constants::error_backref,
    //  70  internal error: unknown opcode in find_fixedlength()
    regex_constants::error_type::_enum_error_last,
    //  71  \N is not supported in a class
    regex_constants::error_ctype,
    //  72  too many forward references
    regex_constants::error_backref,
    //  73  disallowed Unicode code point (>= 0xd800 && <= 0xdfff)
    regex_constants::error_escape,
    //  74  invalid UTF-16 string (specifically UTF-16)
    regex_constants::error_collate,
    //  75  name is too long in (*MARK), (*PRUNE), (*SKIP), or (*THEN)
    regex_constants::error_complexity,
    //  76  character value in \u.... sequence is too large
    regex_constants::error_escape,
    //  77  invalid UTF-32 string (specifically UTF-32)
    regex_constants::error_collate,
    //  78  setting UTF is disabled by the application
    regex_constants::error_collate,
    //  79  non-hex character in \x{} (closing brace missing?)
    regex_constants::error_escape,
    //  80  non-octal character in \o{} (closing brace missing?)
    regex_constants::error_escape,
    //  81  missing opening brace after \o
    regex_constants::error_brace,
    //  82  parentheses are too deeply nested
    regex_constants::error_complexity,
    //  83  invalid range in character class
    regex_constants::error_range,
    //  84  group name must start with a non-digit
    regex_constants::error_backref,
    //  85  parentheses are too deeply nested (stack check)
    regex_constants::error_stack
};


}


#endif
