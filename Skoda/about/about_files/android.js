
$(function(){
    
    $(".mobile-beard-details").on('click', function (e){
        if (window.Android) {
            e.preventDefault();
            Android.beard(JSON.stringify($(this).data('info')));
        }
    });
    $('.js-more-single').click(function(e){
        e.preventDefault();
        var link = $(this);
        if (link.data('target')) {
            $('[data-id="' + link.data('target') + '"]').removeClass('hide');
        }
        if (link.hasClass('autohide')) {
            link.closest('li,article').remove();
        } else {
            if (link.hasClass('opened')) {
                // hide all targets
                $('[data-id="' + link.data('target') + '"]').addClass('hide');
                link.removeClass('opened');
            } else {
                link.addClass('opened');
            }
        }
    });
    
});



    