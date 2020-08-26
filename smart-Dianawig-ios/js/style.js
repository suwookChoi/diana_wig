
/*------------------------------------
date: 2020.06
developed by: smartport
developer url: http://www.smartport.kr
------------------------------------*/




$(function () {



    
// style start




    //* select *//
    // open + close
    $('.slctBox .val').click(function(){
        var $this = $(this).parent('.slctBox');
        // close
        if ( $this.hasClass('on') ){
            $this.removeClass('on tag').children('ul').fadeOut(100);
        //open
        } else {
            $('.slctBox.on').not($this).removeClass('on').children('ul').fadeOut(100);
            $('.smenu.on').removeClass('on').children('ul').fadeOut(100);
            $this.addClass('on tag').children('ul').fadeIn(100);
        }
    });
    // close : select li
    $('.slctBox > ul > li').click(function(){
        var slctTxt = $(this).children('span').text();
        var $slctBox = $(this).parents('.slctBox');
        $slctBox.find('button.val > span').text(slctTxt);
        $slctBox.removeClass('on').children('ul').fadeOut(100);
    });
    // select2(jqueryUI)
    $( ".slctBoxJq > div > select").selectmenu();


    //* daterangepicker*//
    $('.dateRgBox .val').daterangepicker({
        locale: {
            separator: '     ~     ',
        }
        //"startDate": "09/14/2018",
        //"endDate": "09/18/2018",
    });
    $('.dateRgBox.Sg .val').daterangepicker({
        singleDatePicker: true,
        showDropdowns: true,
        locale: {
            applyLabel: 'Done',
            cancelLabel: 'Cancle',
        }
    });
    $('.dateRgBoxTm .val').daterangepicker({
          timePicker: true,
          locale: {
            format: 'Y.MM.DD     hh:mm a',
            separator: '    ~    ',
          }
    });
    
    
    //* scroll table *//
    function scrVs() {
        $('.scrVs').each(function(){
            var $this = $(this);
            var $scrWrap = $this.parents('.txt').parent('.scrWrap');

            if( $scrWrap.height() > $('.conWrap').height() ){
                $scrWrap.height( $('.conWrap').height() );
                var $txtH = $scrWrap.height() - $scrWrap.find('.ttl').height();
                $this.parents('.txt').height( $txtH );
                if( $this.height() > $txtH ){
                    $scrWrap.addClass('scrOn');
                }else{
                    $scrWrap.removeClass('scrOn');
                }
            }else{
                $scrWrap.height('auto');
            }
        });
    }
    /* fix th & Scroll horizontally */
    function scrHrz(){
        $('.scrHWrapL .scrHtxt').scroll(function() {
            $('.scrHWrapX .scrHtxt').scrollLeft( $('.scrHWrapL .scrHtxt').scrollLeft() );
        });
        $('.scrHWrapX .scrHtxt').scroll(function() {
            $('.scrHWrapL .scrHtxt').scrollLeft( $('.scrHWrapX .scrHtxt').scrollLeft() );
        });
    }

    scrVs();
    scrHrz();
    $('.scrClicker').click(function(){
        setTimeout(function(){
            scrVs();
            scrHrz();
        }, 10);
    });

    
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


    //* toggleList *// - 사용하지않음
    $('.tgLWrap .tgList .tgBtn').click(function(){
        var $tgList = $(this).parents('.tgList');
        $tgList.toggleClass('tgLOn');
        $tgList.find('.tgCont').slideToggle(300);
        // other list slideUp
        if( $tgList.hasClass('tgLOn') ){
            $tgList.siblings('.tgList').find('.tgCont').slideUp(300);
            $tgList.siblings('.tgList').removeClass('tgLOn');
        }
    });
    
    
    //* list *// - allView로 인해 새로 짬
    $('.sdBtn').click(function(){
        var $this = $(this);
        var $sdList = $this.parents('.sdList');
        if( !$sdList.hasClass('sdOn') ){ //open
            $sdList.addClass('sdOn').find('.sdCont').slideDown(300);
            $sdList.siblings('.sdList').removeClass('sdOn').find('.sdCont').slideUp(300);
            $('.sdAll').removeClass('on');
        }else{ //close
            $sdList.removeClass('sdOn').find('.sdCont').slideUp(300);
            $('.sdAll').removeClass('on');
        }
    });
    $('.sdAll').click(function(){ //allView
        if( !$(this).hasClass('on') ){ //open
            $('.sdList').addClass('sdOn').find('.sdCont').slideDown(300);
            $(this).addClass('on');
        }else{ //close
            $('.sdList').removeClass('sdOn').find('.sdCont').slideUp(300);
            $(this).removeClass('on');
        }
    });
    
    
    //* check/radio *//
    $('.chkBox > .ipt').click(function(){
        var $this = $(this).parent('.chkBox');
        // remove check
        if ( $this.hasClass('on') ){
            $this.removeClass('on');
            $this.find('.ipt').val('체크안됨');
            $this.find('.ipt').attr('checked', false);
            // All
            if( $this.hasClass('all') ){
                var $chk = $this.parents('.chkWrap').find('.chkBox');
                $chk.removeClass('on');
                $chk.find('.ipt').val('체크안됨');
                $chk.find('.ipt').attr('checked', false);
            }
        // add check
        } else {
            $this.addClass('on');
            $this.find('.ipt').val('체크됨');
            $this.find('.ipt').attr('checked', true);
            // All
            if( $this.hasClass('all') ){
                var $chk = $this.parents('.chkWrap').find('.chkBox');
                $chk.addClass('on');
                $chk.find('.ipt').val('체크됨');
                $chk.find('.ipt').attr('checked', true);
            }
        }
        // All check
        var chklen = $this.parents('.chkWrap').children('.chkBox').length - 1;
        var chkOnlen = $this.parents('.chkWrap').children('.chkBox.on').not('.chkBox.all').length;
        var chkAll = $this.parents('.chkWrap').children('.chkBox.all');
        if ( chklen == chkOnlen ){
            chkAll.addClass('on');
            chkAll.find('.ipt').val('체크됨');
            chkAll.find('.ipt').attr('checked', true);
        } else {
            chkAll.removeClass('on');
            chkAll.find('.ipt').val('체크안됨');
            chkAll.find('.ipt').attr('checked', false);
        }
    });
    $('.rdoBox > .ipt').click(function(){
        var $this = $(this).parent('.rdoBox');
        $this.addClass('on');
        $this.find('.ipt').val('체크됨');
        $this.find('.ipt').attr('checked', true);
        $this.siblings('.rdoBox').removeClass('on');
        $this.siblings('.rdoBox').find('.ipt').val('체크안됨');
        $this.siblings('.rdoBox').find('.ipt').attr('checked', false);
    });
    

    //* tabMenu *//
    $('.tabBtn > .btn').click(function(){
        var $this = $(this);
        var idx = $this.index();
        if ( $this.hasClass('active') ){
            return false;
        } else {
            $this.addClass('active').siblings('.btn').removeClass('active');
            $this.parents('.tabMenu').children('.tabCont').children('.cont').eq(idx).fadeIn(100).addClass('active').siblings('.cont').fadeOut(100).removeClass('active');
        }$('.tabMenu .tabBtn').width(tabBtnW * btnLgh);
    });

    //* tabMenu width *//
    $('.tabMenu').each(function(){
        var tabBtnW = $(this).find('.tabBtn .btn').width();
        var btnLgh = $(this).find('.tabBtn .btn').length;
        $(this).find('.tabBtn').width(tabBtnW * btnLgh);
    });

    //* .popDf *//
    $('.popWrap .popBtn').click(function(){
        if( $(this).hasClass('close') ) {
            $(this).parents('.popWrap').find('.popCont').fadeOut(100).removeClass('on tag');
            $('.fixBG').fadeOut(200);
        } else {
            $(this).parents('.popWrap').find('.popCont').fadeIn(100).addClass('on tag');
            $('.fixBG').fadeIn(200);
        }
    });



// style end



});
