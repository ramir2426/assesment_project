$(document).on('click','.divlink', function(event) {
    event.preventDefault();
    var target = "#" + this.getAttribute('data-target');
    console.log(target);
    $('html, body').animate({
        scrollTop: $(target).offset().top
    }, 300);
});