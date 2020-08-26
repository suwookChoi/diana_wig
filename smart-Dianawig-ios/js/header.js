function header_html(menu,name,logoYn){
    var context ="";
    context += "    <div class='headerData'>";
    if(logoYn == "Y"){
        context += "        <h1 id='logo' class='logo'><a href='javascript:goPage(\"quotations\")'>home</a></h1>";
    } else {
        context += "        <h1 id='logo' class='logo back'><a href='javascript:history.back();'>back</a></h1>";
    }
    context += "        <h2 id='title' class='tit'>"+menu+"</h2>";
    context += "        <button id='menuBar' class='navBtn'>";
    context += "            <span></span>";
    context += "            <span></span>";
    context += "            <span></span>";
    context += "        </button>";
    context += "        <nav class='hdNav'>";
    context += "            <div class='top'>";
    context += "                <div class='usInfoWrap'>";
    context += "                    <p class='usNm'>"+name+"</p>";
    context += "                    <button type='button' class='logOut popBtn' onclick='javascript:logoutPop()'>Log Out</button>";
    context += "                </div>";
    context += "                <button class='cls'>close</button>";
    context += "            </div>";
    context += "            <div class='hnConWrap'>";
    context += "                <ul>";
    context += "                    <li><button class='quotations'type='button' onclick='javascript:goPage(\"quotations\")'>Quotation List</button></li>";
    context += "                    <li><button type='button' class='createQuotation' onclick='javascript:goPage(\"createQuotations\")'>Create Quotation</button></li>";
    context += "                    <li class='report_li'>";
    context += "                        <button type='button' class='Report' onclick='javascript:btn_show();'>Report</button>";
    context += "                        <ul class='subNav'>";
    context += "                          <li><button type='button' class='reportARLedger' onclick='javascript:goPage(\"reportARLedger\")'>A/R Ledger</button></li>";
    context += "                          <li><button type='button' class='reportCheckList' onclick='javascript:goPage(\"reportCheckList\")'>Check List</button></li>";
    context += "                          <li><button type='button' class='reportAmount' onclick='javascript:goPage(\"reportSalesAmount\")'>Sales Amount</button></li>";
    context += "                          <li><button type='button' class='reportSaleItem' onclick='javascript:goPage(\"reportSalesItem\")'>Sales Item List</button></li>";
    context += "                        </ul>";
    context += "                    </li>";
    context += "                </ul>";
    context += "            </div>";
    context += "        </nav>";
    context += "    </div>";
    
    $("#header").html(context);
    // $(".on .subNav").hide();
    $(".report_li ul").hide();
    /* header nav */
    $('.headerData .navBtn').click(function(){
        $(this).siblings('.hdNav').animate({
        right: '0',
        }, 200);
    });
    $('.headerData .hdNav .cls').click(function(){
        $(this).parents('.hdNav').animate({
        right: '-100%',
        }, 200);
    });

    //* nav slide *//
    $(".hdNav > ul > li > button").click(function(){
        if ($(window).width())
        {
            var gsub = $(this).siblings(".lnbConWrap");
            $(".lnbConWrap").not(gsub).slideUp("fast");
            gsub.slideToggle("fast");
            $(".lnb > li").not($(this).parent("li")).removeClass("on");
            $(this).parent("li").toggleClass("on");
            return false;
        }
    });


    //* .popDf *//
//    $('.popWrap .popBtn').click(function(){
//        if( $(this).hasClass('close') ) {
//            $(this).parents('.popWrap').find('.popCont').fadeOut(100).removeClass('on tag');
//            $('.fixBG').fadeOut(200);
//        } else {
//            $(this).parents('.popWrap').find('.popCont').fadeIn(100).addClass('on tag');
//            $('.fixBG').fadeIn(200);
//        }
//    });
  }
