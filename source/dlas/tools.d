module dlas.tools;

import std.string;
import std.conv;
import std.typecons;
import std.variant;
import std.regex;

/**
  * Tries to parse an input string to each of a given types sequentially, if fails, returns a string
  */
Variant stringToVariant(TList...)(string value) {
    Variant result;
    static foreach (T; TList) {
        try {
            result = value.to!T;
            return result;
        } 
        catch (ConvException e) { }
    }
    result = value;
    return result;
}

/**
  * Parses header line and returns log name, measurement unit, value and comment (for LAS 2)
  * or whatever is stored with the same pattern 
  */
Tuple!(string, string, string, string) parseHeaderLine(string line) {
    auto re = ctRegex!"^([^ \\.]+) *\\.([^ ]*) *([^:]*): *([^$]+)?";
    auto match = matchAll(line, re);
    return tuple(match.captures[1], match.captures[2], match.captures[3].strip, match.captures[4]);
}