$(function() {
  const preferencesBtn = $('th.col-table-preferences');
  const tableConfig = $('ul.dynamic_table_configuration');

  if (tableConfig.length) {
    $('#wrapper').css('display', 'block')
  }

  function parseSearchString(searchString) {
    return searchString.split('&').reduce((acc, keyval) => {
      const [key, value] = keyval.split('=');

      if (!key || !value) {
        return acc;
      }

      acc[key] = value;

      return acc;
    }, {});
  }

  function toSearchString(params) {
    return Object.keys(params).map((key) => [key, params[key]].join('=')).join('&')
  }

  function filterEmptyKeys(params) {
    return Object.keys(params).reduce((acc, key) => {
      if (!params[key]) {
        return acc;
      }

      acc[key] = params[key];
      return acc;
    }, {});
  }

  preferencesBtn.on('click', function() {
    const offset = preferencesBtn.offset();
    offset.top += preferencesBtn.outerHeight();

    tableConfig.removeClass('hidden').offset(offset);

    return false;
  });

  document.addEventListener('click', () => {
    if (!tableConfig.length || tableConfig.hasClass('hidden')) {
      return
    }

    const searchString = decodeURIComponent(window.location.search).slice(1);
    let params = parseSearchString(searchString);

    const selected = tableConfig.find('input').filter(function() {
      return $(this).is(':checked');
    }).map(function() {
      return $(this).attr('name');
    });

    params.columns = encodeURIComponent(selected.toArray().join(';'))
    params = filterEmptyKeys(params);

    const nextSearchString = '?' + toSearchString(params);

    tableConfig.addClass('hidden');
    window.location.search = nextSearchString;
  });

  tableConfig.on('click', function(event) {
    event.stopPropagation();
  });

  $('.dynamic_table th').resizable();
});
