module dlas.loader;

import dlas.header;
import dlas.tools;

import std.string;
import std.conv;
import std.stdio; 
import std.file;
import std.variant;
import std.typecons;
import std.algorithm;
import std.regex;
import std.math;


/**
  * Loader class handles loading of a different parts of LAS files
  */
class Loader {

    /**
      * Returns a version for a given file. 1 for 1.x, 2 for 2 and 3 for 3
      * If a given file is not a valid LAS file returns 0
      */
    int lasVersion(string fileName) {
        File file = File(fileName, "r");
        string line;
        auto re = ctRegex!"^([^ \\.]+) *\\.([^ ]*) *([^:]*): *([^$]+)?";
        while (!line.startsWith("VERS")) {
            line = file.readln.chomp.strip;
            if (file.eof)
                return 0;
        }
        auto match = matchAll(line, re);
        if (!match.empty)
            return match.captures[3].strip.to!double.to!int;
        return 0;
    }

    /**
      * Parses a ~W section of a given file and retrieves a delimiter 
      * symbol, if now found returns a single space (" ")
      */

    string delimiter(string fileName) {
        File file = File(fileName, "r");
        string line;
        auto re = ctRegex!"^([^ \\.]+) *\\.([^ ]*) *([^:]*): *([^$]+)?";
        while (!line.startsWith("DLM")) {
            line = file.readln.chomp.strip;
            if (line.startsWith("~W") || file.eof)
                return " ";
        }
        auto match = matchAll(line, re);
        if (!match.empty) {
            immutable string delimiter = match.captures[3].strip;
            if (delimiter == "TAB")
                return "\t";
            else if (delimiter == "COMMA")
                return ",";
        }
        return " ";
    }

    /**
      * Parses LAS file and returns file header information like
      * start MD, stop MD, step etc.
      */
    LasHeaderEntry[string] loadLasHeader(string fileName) {
        immutable int v = lasVersion(fileName);
        LasHeaderEntry[string] result;
        if (v == 0)
            return result;
        File file = File(fileName, "r");
        string line;
        bool reading = false;
        while(!file.eof) {
            line = file.readln.chomp.strip;
            if (line.startsWith("~A"))
                break;
            if (line.startsWith("#"))   // skip comment lines
                continue;
            if (reading) {
                if (line.startsWith("~") && 
                    !(line.startsWith("~W") || line.startsWith("~P")))
                    reading = false;
                else {
                    auto h = parseHeaderLine(line);
                    LasHeaderEntry entry;
                    entry.name = h[0];
                    entry.unit = h[1];
                    entry.value = stringToVariant!(int, double)(h[2]);
                    entry.comment = h[3];
                    result[entry.name] = entry;
                }
            }
            else {
                if (line.startsWith("~W") || line.startsWith("~P"))
                    reading = true;
            }
        }
        return result;
    }

    /**
      * Parses LAS header and returns data header info: curve name, measurement unit and comment
      */
    LasDataHeaderEntry[] loadLasDataHeader(string fileName) {
        immutable int v = lasVersion(fileName);
        immutable string curveInformationToken = v == 3 ? "~curve" : "~c";
        LasDataHeaderEntry[] result;
        File file = File(fileName, "r");
        string line;
        while(!line.startsWith(curveInformationToken)) {    // skip everything until ~C token
            line = file.readln.chomp.strip.toLower;
            if (file.eof)
                throw new Exception("Curve information section not found");
        }
        while(!file.eof) {
            line = file.readln.chomp.strip;
            if (line.startsWith("#"))   // skip comment lines
                continue;
            if (line.startsWith("~"))   // new block started
                break;
            auto h = parseHeaderLine(line);
            LasDataHeaderEntry entry;
            entry.name = h[0];
            entry.unit = h[1];
            entry.apiCode = h[2];
            entry.comment = h[3];
            result ~= entry;
        }
        return result;
    }

    /**
      * Parses LAS file data section and returns data as a number of arrays
      */
    double[][] loadLasData(string fileName) {  
        immutable int v = lasVersion(fileName);
        immutable string dlm = delimiter(fileName);


        auto header = loadLasHeader(fileName);
        LasHeaderEntry nullEntry;
        foreach (he; header) {
            if (he.name == "NULL") {
                nullEntry = he;
                break;
            }
        }
        immutable double nullValue = nullEntry.name.empty ? -999.25 : nullEntry.value.get!double;

        auto dataHeader = loadLasDataHeader(fileName);

        double[][] result;
        result = new double [][dataHeader.length];

        File file = File(fileName, "r");
        string line;
        while(!line.startsWith("~A")) {
            line = file.readln.chomp.strip;
            if (file.eof)
                throw new Exception("ASCII data section not found");
        }

        auto re = regex(dlm ~ "(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
        double [] batch;    // stores a batch of data (one line) in a numeric view 
        string [] words;    // stores a splitted representation of a line
        while(!file.eof) {
            line = file.readln.chomp.strip;
            if (line.startsWith("#"))
                continue;
            if (dlm == " ") {
                words = line.split();
            }
            else {
                words = split(line, re);
            }
            foreach (word; words) {
                try {
                    immutable double value = word.to!double;
                    if (approxEqual(value, nullValue))
                        batch ~= double.nan;
                    else
                        batch ~= value;
                }
                catch (ConvException e) {
                    batch ~= double.nan;
                }
            }
            if (batch.length == dataHeader.length) {
                for (size_t i = 0; i < batch.length; i++)
                    result[i] ~= batch[i];
                batch = [];
            }
            else if (batch.length > dataHeader.length)
                throw new Exception("Bad wrapped data in LAS file");
        }
        return result;
    }

}

