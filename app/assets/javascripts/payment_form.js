$(function() {

  // Card validations
  $('input.cc-num').payment('formatCardNumber');
  $('input.cc-cvc').payment('formatCardCVC');
  $('input.cc-exp').payment('formatCardExpiry');

  // Stripe
  function stripeResponseHandler(status, response) {
    var $form = $('#payment-form-stripe');

    if (response.error) {
      $form.find('.payment-errors').text(response.error.message);
      $('#payment-form-stripe input[type=submit]').attr('disabled', false);
      $('#payment-form-stripe input[type=submit]').removeClass("btn-success");
      $('#payment-form-stripe input[type=submit]').addClass("btn-danger");
      $('#payment-form-stripe input[type=submit]').val("CARD REJECTED");
    } else {

      $.post('/charge_card.json', {
        client_payment_nonce: response.id,
        gateway: 'stripe',
        secure_id: $('#secure_id').val()
      })
      .success(function () {
        location.reload(true);
      })
      .error(function() {
        $('#payment-form-stripe input[type=submit]').attr('disabled', false);
        $('#payment-form-stripe input[type=submit]').removeClass("btn-success");
        $('#payment-form-stripe input[type=submit]').addClass("btn-danger");
        $('#payment-form-stripe input[type=submit]').val("CARD REJECTED");
      });
    }
  }

  $('#payment-form-stripe').submit(function(event) {

    var expiration = $.payment.cardExpiryVal($('.cc-exp').val());

    Stripe.card.createToken({
        number: $('.cc-num').val(),
        cvc: $('.cc-cvc').val(),
        exp_month: (expiration.month || 0),
        exp_year: (expiration.year || 0)
    }, stripeResponseHandler);

    $('#payment-form-stripe input[type=submit]').removeClass("btn-danger");
    $('#payment-form-stripe input[type=submit]').addClass("btn-success");
    $('#payment-form-stripe input[type=submit]').attr('disabled', true);
    $('#payment-form-stripe input[type=submit]').val("Processing...");

    return false;
  });

  // Braintree
  function braintreeResponseHandler(error, clientPaymentToken) {
    $.post('/charge_card.json', {
      client_payment_nonce: clientPaymentToken,
      gateway: 'braintree',
      secure_id: $('#secure_id').val()
    })
    .success(function () {
      location.reload(true);
    })
    .error(function() {
      $('#payment-form-braintree input[type=submit]').attr('disabled', false);
      $('#payment-form-braintree input[type=submit]').removeClass("btn-success");
      $('#payment-form-braintree input[type=submit]').addClass("btn-danger");
      $('#payment-form-braintree input[type=submit]').val("CARD REJECTED");
    });
  }

  $('#payment-form-braintree').submit(function(event) {

    var expiration = $.payment.cardExpiryVal($('.cc-exp').val());

    var client = new braintree.api.Client({clientToken: $('#braintree-client-nonce').data("braintree-client-nonce")});

    client.tokenizeCard({
      number: $('.cc-num').val(),
      expirationMonth: (expiration.month || 0),
      expirationYear: (expiration.year || 0),
      cvv: $('.cc-cvc').val(),
    }, braintreeResponseHandler);

    $('#payment-form-braintree input[type=submit]').removeClass("btn-danger");
    $('#payment-form-braintree input[type=submit]').addClass("btn-success");
    $('#payment-form-braintree input[type=submit]').attr('disabled', true);
    $('#payment-form-braintree input[type=submit]').val("Processing...");

    return false;
  });
});