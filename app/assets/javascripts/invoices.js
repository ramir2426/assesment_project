$(function() {

  $('.date-input').datepicker({
    autoclose: true,
    todayHighlight: true,
    format: 'yyyy-mm-dd'
  });

  $('#invoice_payment_gateway').change(function() {
    if ($('#invoice_payment_gateway').val() === 'braintree') {
      $('#braintree-fx-notice').removeClass('hidden');
    } else {
      $('#braintree-fx-notice').addClass('hidden');
    }
  });

  $('#hide-braintree-fx-notice').click(function(){
    $.get("/hide_braintree_fx_notice", function(data) {
      $('#braintree-fx-notice').addClass('hidden');
    });
  });

  var invoiceItems = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: '/invoice_items.json'
  });

  invoiceItems.clearPrefetchCache();
  invoiceItems.initialize();

  $('.invoice-item-autocomplete').typeahead({
    minLength: 0,
    highlight: true
  },
  {
    source: invoiceItems
  });

  $('[data-toggle="tooltip"]').tooltip();

  function bindInvoiceItemsWatch() {
    $('.item-description:last').on('input change paste keyup', function(){
      if ($('.item-description:last').val() !== "") {
        var last_row_number = $('.item-description:last').data("id");
        var current_row_number = last_row_number + 1;

        var new_row = '<tr class="invoice-items">';
        new_row += '<td><input type="text" ' + 'data-id="' + current_row_number + '"' + 'name="invoice_items[' + current_row_number + '][description]" id="invoice_items_0_description" class="full-width item-description invoice-item-autocomplete_' + current_row_number + '"></td>';
        new_row += '<td class="text-center"><input type="number" step="any" name="invoice_items[' + current_row_number + '][qty]" id="invoice_items_' + current_row_number + '_qty" class="full-width qty"></td>';
        new_row += '<td class="text-center"><input type="number" step="any" name="invoice_items[' + current_row_number + '][unit_price]" id="invoice_items_' + current_row_number + '_unit_price" class="full-width unit-price"></td>';
        new_row += '<td class="text-right"><span class="total">0.0</span> USD</td>';
        new_row += '</tr>';

        $('.invoice-items:last').after(new_row);

        console.log('binding ' + current_row_number);
        $('.invoice-item-autocomplete_' + current_row_number).typeahead({
          minLength: 0,
          highlight: true
        },
        {
          name: 'invoiceItems',
          source: invoiceItems
        });

        bindInvoiceItemsWatch();
      }
    });

    $('.invoice-items .qty, .invoice-items .unit-price').on('input change paste keyup', function(){
      var qty = $(this).parent().parent().find(".qty").val();
      var unit_price = $(this).parent().parent().find(".unit-price").val();

      var result = qty * unit_price;

      if (isNaN(result)) { result = 0; }

      $(this).parent().parent().find(".total").text(result.toFixed(2));
      $(this).parent().parent().find(".total").trigger('change');
    });

    $('.invoice-items .total, .tax_amount').on('input change paste keyup', function(){
      var subtotal = 0;

      $('.invoice-items .total').each(function() {
        subtotal += Number($(this).text());
      });

      if (isNaN(subtotal)) { subtotal = 0; }

      var tax = Number($('.tax_amount').val());
      $('.subtotal').text(subtotal);
      $('.totals').text((subtotal + tax).toFixed(2));
    });

    $('.invoice_currency').change(function(){
      $('.invoice-currency').text($(this).val());
    });

    $('.invoice_client_id').change(function(){
      $('#invoice-to-client').show();
      $('#invoice-to-client').html($(this).find(':selected').data("to-company").replace(/(\r\n|\n\r|\r|\n)/g, "<br>"));
      $('#invoice-to-client').show();
      $('.invoice_client_id').hide();
    });

    $('#invoice-to-client').click(function(){
      $('#invoice-to-client').hide();
      $('.invoice_client_id').show();
      $('.invoice_client_id').val(0);
    });
  };

  bindInvoiceItemsWatch();
});