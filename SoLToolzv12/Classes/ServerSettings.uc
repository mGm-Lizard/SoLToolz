class ServerSettings extends Object Config(SoLToolz);

struct Details {
    var string Setting;
    var string Value;
};
var config bool bReportServerAsDM;
var config string ServerColorName;
var config string MapColorPrefix;
var config array<Details> ServerDetails;
