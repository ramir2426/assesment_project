$(function() {

  // Card validations
  $('input.cc-num').payment('formatCardNumber');
  $('input.cc-cvc').payment('formatCardCVC');
  $('input.cc-exp').payment('formatCardExpiry');

  // Braintree
  function braintreeResponseHandler(error, clientPaymentToken) {
    $.post('/subscription_plans.json', {
      client_payment_nonce: clientPaymentToken,
      plan_name: $('#plan_name').val()
    })
    .success(function () {
      window.location = '/subscription_plans';
    })
    .error(function(){
      $('#subscription-plan-form input[type=submit]').attr('disabled', false);
      $('#subscription-plan-form input[type=submit]').removeClass("btn-success");
      $('#subscription-plan-form input[type=submit]').addClass("btn-danger");
      $('#subscription-plan-form input[type=submit]').val("CARD REJECTED");
    });
  }

  $('#subscription-plan-form').submit(function(event) {

    var expiration = $.payment.cardExpiryVal($('.cc-exp').val());

    var client = new braintree.api.Client({clientToken: $('#braintree-client-nonce').data("braintree-client-nonce")});

    client.tokenizeCard({
      number: $('.cc-num').val(),
      expirationMonth: (expiration.month || 0),
      expirationYear: (expiration.year || 0),
      cvv: $('.cc-cvc').val(),
    }, braintreeResponseHandler);

    $('#subscription-plan-form input[type=submit]').removeClass("btn-danger");
    $('#subscription-plan-form input[type=submit]').addClass("btn-success");
    $('#subscription-plan-form input[type=submit]').attr('disabled', true);
    $('#subscription-plan-form input[type=submit]').val("Processing...");

    return false;
  });

  $('#subscription-plan-change').submit(function(event) {

    $('#subscription-plan-change input[type=submit]').removeClass("btn-danger");
    $('#subscription-plan-change input[type=submit]').addClass("btn-success");
    $('#subscription-plan-change input[type=submit]').attr('disabled', true);
    $('#subscription-plan-change input[type=submit]').val("Processing...");

    $.ajax({
       url: 'subscription_plans.json',
       type: 'PUT',
       data: { plan_name: $('#plan_name').val() },
       success: function(response) {
         window.location = '/subscription_plans';
       },
       error: function() {
        //$('#plan-card-container').removeClass('hidden');
        //$('#plan-change-container').addClass('hidden');

        $('#subscription-plan-form input[type=submit]').attr('disabled', false);
        $('#subscription-plan-form input[type=submit]').removeClass("btn-success");
        $('#subscription-plan-form input[type=submit]').addClass("btn-danger");
        $('#subscription-plan-form input[type=submit]').val("CARD REJECTED");
       }
    });

    return false;
  });
});