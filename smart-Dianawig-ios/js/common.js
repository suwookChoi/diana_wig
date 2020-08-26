function loadingStart(options){
    var option = options || {};
    var left = 0;
    var top = 0;
    var img = 'loading_bar.gif';
    var opacity = 0.7;
    var targetWin = option.tWin || window.top;

    width = 200;
    height = 30;
    left = ( $(targetWin).width() -  width) / 2 + $(targetWin).scrollLeft();
    top = ( $(targetWin).height() -  height) / 2 + $(targetWin).scrollTop();

    var strTag = '';
    strTag += '<div id="loading-layout" onclick="loadingEnd();" style="position:fixed; ';
    strTag += 'top:0px;left:0px;width:100%;height:100%;';
    strTag += 'display:block; z-index:9999; margin:auto; padding:0; background-color: black; ';
    strTag += 'filter:alpha(opacity=' + (opacity * 50) + '); opacity:0.7;">';
    strTag += '<img id="loading-img" src="loading_bar.gif" ';
    strTag += '" style="position: absolute; top:'+top+'px; left:'+left+'px; width:'+width+'px; height:'+height+'px; z-index:10000;"/>';
    strTag += '<div style="position : absolute; top:'+(top+30)+'px; font-size:17px; color:gray; z-index:10000; width:100%; text-align:center; ">Synchronizing data';
    strTag += '</div>';
    strTag += '</div>';

    $(targetWin.document.body).append(strTag);
}

function loadingEnd(options) {
    var option = options || {};
    $((option.tWin || window.top).document).find('#loading-layout').remove();
}

function goPage(pageName){
    window.webkit.messageHandlers.menu.postMessage(pageName);
}

// Alert 팝업  : 해당 페이지에 아래 항목 추가
// <div class="popWrap" id="popWrap_div" style="text-align: center;"></div>
// <div class="fixBG"></div>

function showAlert(title,text){
    var context = "";
    context +='        <div class="popCont"> ';
    context +='            <div class="contents">';
    context +='                <p class="popTit">'+title+'</p> ';
    context +='                <span>'+text+'</span>';
    context +='                <div class="popBtnWrap">';
    context +='                    <button type="button" class="popBtn close" title="OK" onclick="javascript:popup_Close()">OK</button>';
    context +='                </div>';
    context +='            </div>';
    context +='        </div>';
    
    $("#popWrap_div").html(context);
    $("#popWrap_div").find(".popCont").fadeIn(100).addClass('on tag');
    $('.fixBG').fadeIn(200);
}
function popup_Close(){
    $("#popWrap_div").html("");
    $("#popWrap_div").find(".popCont").fadeOut(100).removeClass('on tag');
    $('.fixBG').fadeOut(200);
}


var flag = false;
function btn_show(){
    if(!flag)  {
        $(".report_li ul").show();
        flag=true;
    }
    else {
        $(".report_li ul").hide();
        flag = false;
    }
}

// 로그아웃
function logoutPop(){
    $('.headerData .hdNav .cls').click();
    
    var context = "";
    context += '<div class="popWrap" id="logoutPopup">';
    context += '        <div class="popCont logout">';
    context += '            <div class="contents">';
    context += '                <p class="popTit">Do you want to log out?</p>';
    context += '                <div class="popBtnWrap">';
    context += '                    <button type="button" class="popBtn close" onclick="javascript:logout()" title="OK">OK</button>';
    context += '                    <button type="button"class="popBtn close cancel" onclick="javascript:logout_close()" title="CANCEL">CANCEL</button>';
    context += '                </div>';
    context += '            </div>';
    context += '        </div>';
    context += '   </div>';
    context += '   <div class="fixBG"></div>';
    
    $("#header").append(context);
    
    $('.popWrap').children('.popCont').fadeIn(100).addClass('on tag');
    $('.fixBG').fadeIn(200);
}
function showAlert_OKcheck(title,text){
    var context = "";
    context +='        <div class="popCont"> ';
    context +='            <div class="contents">';
    context +='                <p class="popTit">'+title+'</p> ';
    context +='                <span>'+text+'</span>';
    context +='                <div class="popBtnWrap">';
    context +='                    <button type="button" class="popBtn close" title="OK" onclick="javascript:checkOK()">OK</button>';
    context +='                </div>';
    context +='            </div>';
    context +='        </div>';

    $("#popWrap_div").html(context);
    $("#popWrap_div").find(".popCont").fadeIn(100).addClass('on tag');
    $('.fixBG').fadeIn(200);
}

function logout(){
    window.webkit.messageHandlers.logout.postMessage("logout");
}

function logout_close(){
    $('.popWrap').children('.popCont').fadeOut(100).removeClass('on tag');
    $('.fixBG').fadeOut(200);
    $("#logoutPopup").parents().find("#logoutPopup").html("");
}

// 로딩바
function loading_bar(){
    var context = "";
    context +='<div class="popCont loadingBar"> ';
    context +='    <div class="contents">';
    context +='        <img src="loading_bar.gif" alt="loading_bar">';
    context +='    </div>';
    context +='</div>';
    
    $("#popWrap_div").html(context);
    $("#popWrap_div").find(".popCont").fadeIn(100).addClass('on tag');
    $('.fixBG').fadeIn(200);
    
}
// 숫자 자릿수 맞추기 (ex :  1 -> 01)
function pad(n, width) {
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
}

function networkChk() {
    showAlert("Notice","Please check the network.");
}

function error() {
    showAlert("Error","Please contact the administrator.");
}
