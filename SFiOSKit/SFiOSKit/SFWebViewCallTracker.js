var SFKeyCallIdValueFunc = {};

function SFNativeCall(methodName, callbackFunc) {
    SFNativeCallWithParams(methodName, null, callbackFunc);
}

function SFNativeCallWithParams(methodName, params, callbackFunc) {
    var callId = "call_" + (new Date().getTime() + parseInt(Math.random() * 10000000));
    SFKeyCallIdValueFunc[callId] = callbackFunc;
    
    var url = "SFNativeCall://" + methodName + "?_callback_func=_SFNativeCallback&_user_data=" + callId;
    if (params != null && params != undefined) {
        url = url + "&" + params;
    }
    
    window.location.href = url;
}

function _SFNativeCallback(callId, resultValue) {
    if (callId != undefined && callId != null) {
        var func = SFKeyCallIdValueFunc[callId];
        func(resultValue);
        delete SFKeyCallIdValueFunc[callId];
    }
}