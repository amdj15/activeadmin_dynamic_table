$(function() {
  const preferencesBtn = $('th.col-table-preferences');
  const tableConfig = $('ul.dynamic_table_configuration');

  const columnsPattern = 'th[data-column-key]';
  const columns = $(columnsPattern);

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

  function stringifyParams(params) {
    const data = filterEmptyKeys(params);
    const prefix = '?';
    const searchString = Object.keys(data).map((key) => [key, data[key]].join('=')).join('&');

    return searchString ? prefix + searchString : '';
  }

  function columnsConfigString(keys, sizes = {}) {
    const str = keys.map(key => {
      if (sizes[key]) {
        return [key, 'w' + sizes[key]].join(':');
      }

      return key;
    }).join(';');

    return encodeURIComponent(str);
  }

  function getSearchParams() {
    const searchString = decodeURIComponent(window.location.search).slice(1);

    return parseSearchString(searchString);
  }

  function getColumnsWidths() {
    return columns.map(function() {
      const elem = $(this)

      return {
        width: elem.width(),
        key: elem.data('column-key'),
      };
    })
    .toArray()
    .reduce((acc, item) => Object.assign(acc, { [item.key]: item.width }), {});
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
      return;
    }

    const selected = tableConfig.find('input').filter(function() {
      return $(this).is(':checked');
    }).map(function() {
      return $(this).attr('name');
    }).toArray();

    const current = $(columnsPattern).map(function() {
      return $(this).data('column-key');
    }).toArray().filter(key => selected.includes(key));

    const diff = selected.filter(key => !current.includes(key));

    const columnSizes = getColumnsWidths();
    const params = Object.assign(getSearchParams(), {
      columns: columnsConfigString(current.concat(diff), columnSizes),
    });
    const searchString = stringifyParams(params);

    tableConfig.addClass('hidden');
    window.location.search = searchString;
  });

  tableConfig.on('click', function(event) {
    event.stopPropagation();
  });

  columns.resizable({
    stop: function() {
      const columnSizes = getColumnsWidths();
      const params = Object.assign(getSearchParams(), {
        columns: columnsConfigString(Object.keys(columnSizes), columnSizes),
      });

      const searchString = stringifyParams(params);
      window.location.search = searchString;
    },
  });

  $('.index_as_dynamic_table thead tr').sortable({
    axis: 'x',
    update: function() {
      const columnSizes = getColumnsWidths();
      const keys = $(columnsPattern).map(function() {
        return $(this).data('column-key');
      }).toArray();

      const params = Object.assign(getSearchParams(), {
        columns: columnsConfigString(keys, columnSizes),
      });

      const searchString = stringifyParams(params);
      window.location.search = searchString;
    },
  });
});
