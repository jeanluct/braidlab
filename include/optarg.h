/*
    Copyright (C) 2000-2001 Jae Choon Cha.

    This file is part of CBraid.

    CBraid is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    any later version.

    CBraid is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with CBraid; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/


/*
    $Id: optarg.h,v 1.1 2001/12/07 10:12:14 jccha Exp $
    Jae Choon CHA <jccha@knot.kaist.ac.kr>

    This is optarg, a C++ subroutine for command line option processing.
*/


#ifndef _OPTARG_H
#define _OPTARG_H


/*
    Optarg processes options, that are usually used to specify things
    related to some actions of a program by means of command line
    arguments.  It parses options, and possibly their arguments, and
    store the values of arguments in given variables.

    Options and their arguments are given as a sequence of
    std::string, or something which can be translated to
    std::string. The sequence will be called option-argument
    sequence. An example is the command line arguments transferred
    through argc and argv arguments of main() function.

    Usually an option consists of a dash sign followed by its name,
    like -v, -with-braid and -filename, even though optarg does not
    require this. (For example, options with doube-dash like
    --longoption are allowed). Sometimes different options have the
    same meanings, and in this case, one has short and easy-to-type
    name and the other one has long and descriptive name, like -v and
    -verbose.  To separate words in option names, usually dash signs
    are used instead of spaces, like --show-char-table.

    Options can have (possibly more than one) arguments.

    In the option-argument sequence to be parsed, one string
    represents either one option or one argument, like -v -a --order
    10 -f myfile.c. Arguments follows the option that they belongs
    to. The first argument can be given as a part of the string
    containing the option, where an equal sign is used to separate the
    option name and the argument, like -filename=myfile.c.

    Arguments can be one of the following types: numeric, string,
    boolean. A numeric argument is a decimal integer which can be
    stored in int type. A string argument is a sequence of characters
    and stored in string type (that is provided by C++ standard
    library). The last one type, boolean, is special. There are two
    subtypes, bool_true_arg and bool_false_arg. No real argument (as a
    part of strings that are being parsed) should follow an option
    with bool_true_arg type argument. The argument value is
    automatically set to true. Similary for options with bool_false
    arguments. In other words, an option with a boolean argument has a
    fixed value of its argument. If an option has a boolean argument,
    then it cannot have any other arguments.

    The process_option() function parses options. Its syntax is as
    follows.

    iterator optarg::process_option(iterator first, iterator last,
                                const optarg::optlist& m);

    where first and last point the start and the next one of the last
    string, i e [first, last[ is the option-argyment string to be
    parsed.  [first, last[ must be a sequence of a type which can be
    casted to std::string. m describes the names of options with their
    arguments, and furthermore, where to store the argument
    values. For example,

    int main(int argc, char* argv)
    {
        string& filename;
        int first = 1, last = 10;
        bool verbose = false;

        process_option(argv, argv+argc,
            optmap() << opt("-f",         string_arg,    &filename)
                     << opt("-filename", string_arg,    &filename)
                     << opt("-v",         bool_true_arg, &verbose)
                     << opt("-verbose",  bool_true_arg, &verbose)
                     << opt("-range",
                         arglist() << arg(int_arg, &first)
                                   << arg(int_arg, &last)));
        ...
    }

    processes three options: -f (-filename), -v (-verbose) and
    -range. -f has one string argument. -v has a bool_true
    argument. -range has two integer arguments. For example, if the
    command line argument is -f myfile.c --range 2 7, then after the
    call of process_option(), the values of filename, first, last,
    verbose is "myfile.c", 2, 7, false, respectively.

    process_option() returns an iterator pointing the first string in
    the option-argument sequence that is not processed since it is
    neither an option nor an argument of a preceeding option.  If the
    entire sequence is processed, last is returned.

    If some argument is missing, bad_optarg_seq exception is
    thrown. If the last argument of process_option() is invalid,
    bad_optmap exception is thrown.

*/


#include <algorithm>
#include <list>
#include <map>
#include <string>


namespace OptArg {

    // Kinds of arguments.
    enum argtype {
        int_arg,
        string_arg,
        bool_true_arg,
        bool_false_arg,
        undefined_arg
    };


    // Argument description type. It is just a pair of argument type
    // and a pointer to the memory where the value will be stored.
    typedef std::pair<enum argtype, void*> arg;


    // Argument list type.
    typedef std::list<arg> arglist;


    // operator<<() adds argument descriptions to an argument list.
    // It is better than push_back() in adding several argument
    // descriptions at once, like arglist() << arg(..,..) <<
    // arg(..,..);
    arglist& operator<<(arglist& al, const arg& ad);


    // Option description type.  This is just a pair of a string and
    // an arglist, with constructors which are very convinient in
    // describing simple but frequent options.
    struct opt : public std::pair<std::string, arglist> {
        opt(const std::string& n, const arglist& al);
        opt(const std::string& n, const arg& a);
        opt(const std::string& n, enum argtype t, void* p);
    };


    // Option mapping type.
    typedef std::map<std::string, arglist> optmap;

    // operator<<() adds option descriptions to an option mapping,
    // similarly to the case of arglist type.
    optmap& operator<<(optmap& m, const opt& op);


    // Process options.
    template<class InItr>
        InItr process_option(InItr first, InItr last, const optmap& m);

    // Exceptions that are thrown by process_option().

    struct bad_optarg_seq {
        bad_optarg_seq(const std::string& n = std::string()) : option_name(n) {}
        std::string option_name;
    };

    struct bad_optmap {};


} // namespace optarg



// Implementations.

// Because export template is not supported by many compilers,
// functions including fairly long one are implemented in this header
// file.


OptArg::arglist& OptArg::operator<<(arglist& al, const arg& ad)
{
    al.push_back(ad);
    return al;
}


OptArg::opt::opt(const std::string& n, const arglist& al)
    : std::pair<std::string, arglist>(n, al)
{}


OptArg::opt::opt(const std::string& n, const arg& a)
{
    first = n;
    second << a;
}


OptArg::opt::opt(const std::string& n, enum argtype t, void* p)
{
    first = n;
    second << arg(t, p);
}


OptArg::optmap& OptArg::operator<<(optmap& m, const opt& op)
{
    m[op.first] = op.second;
    return m;
}


template<class InItr>
InItr OptArg::process_option(InItr first, InItr last, const optmap& m)
{
    while (first != last) {

        // Check whether *first is a valid option. It extracts the
        // option name and store in OptName. If *first contains '=',
        // the substring after '=' is considered as the first argument
        // and stored in PreArg.
        std::string OptName = *first;
        bool bPreArg = false;
        std::string PreArg;
        std::string::size_type p = OptName.find("=");
        if (p != std::string::npos) {
            bPreArg = true;
            PreArg = OptName.substr(p+1);
            OptName = OptName.substr(0, p);
        }

        optmap::const_iterator i = m.find(OptName);
        if (i == m.end()) {
            // OptName is not a valid option.  This is considered as
            // the end of options.
            return first;
        }

        // Process arguments.
        ++first;
        const arglist& al = i->second;
        for(arglist::const_iterator j = al.begin(); j != al.end(); ++j) {
            if (j->first == bool_true_arg || j->first == bool_false_arg) {
                if (++(al.begin()) != al.end()) {
                    // Error in m: There are other arguments.
                    throw bad_optmap();
                }
                *static_cast<bool*>(j->second) =
                    (j->first == bool_true_arg) ? true : false;
            } else {
                std::string Arg;
                if (bPreArg) {
                    Arg = PreArg;
                    bPreArg = false;
                } else if (first == last) {
                    // Error in [first, last[: Missing arguments.
                    throw bad_optarg_seq(OptName);
                } else {
                    Arg = *(first++);
                }
                if (j->first == int_arg) {
                    *(static_cast<int*>(j->second)) = std::atoi(Arg.c_str());
                } else if (j->first == string_arg) {
                    *(static_cast<std::string*>(j->second)) = Arg;
                } else {
                    // Error in m: Invalid argument type.
                    throw bad_optmap();
                }
            }
        }
        if (bPreArg) {
            // An argument has been given as a part of the option, but
            // it is not consumed. This is an error in option-argument
            // sequence.
            throw bad_optarg_seq(OptName);
        }
    }
    return first;
}



#endif // _OPTARG_H
