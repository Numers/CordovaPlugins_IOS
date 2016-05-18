
var exec = require('cordova/exec');

module.exports = {
startLocationService:function(SuccessCallBack,ErrorCallBack,value) {
    exec(SuccessCallBack, ErrorCallBack, "Location", "startLocationService", [value]);
},
postLocationStrategy:function(SuccessCallBack,ErrorCallBack,value) {
    exec(SuccessCallBack, ErrorCallBack, "Location", "postLocationStrategy", [value]);
}
};