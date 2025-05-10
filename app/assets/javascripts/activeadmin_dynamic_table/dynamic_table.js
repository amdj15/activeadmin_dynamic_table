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
        width: elem.outerWidth(),
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

  let clone = null;

  preferencesBtn.on('click', function() {
    const offset = preferencesBtn.offset();
    offset.top += preferencesBtn.outerHeight();

    clone = tableConfig.clone();

    clone.removeClass('hidden');
    clone.offset(offset);
    offset.top += preferencesBtn.outerHeight();

    $('.index_content').prepend(clone);

    return false;
  });

  $(document).on('click', '.dynamic_table_configuration', function(event) {
    event.stopPropagation();
  });

  $(document).on('click', () => {
    if (!clone) {
      return;
    }

    const selected = clone.find('input').filter(function() {
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

    clone.remove();
    clone = null;

    window.location.search = searchString;
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
