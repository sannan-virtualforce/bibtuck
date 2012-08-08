var dropdownMenuTimeout;

function openDropdownMenu(menu) {
  var menuLink = $(menu).data('menuLink');
  menuLink.addClass('open');
  menu.show();
  $(document).data('openMenu', menu);
  if (menu.data('isNotificationMenu')) {
    $(document).bind('click', closeOpenDropdownMenu);
  }
}

function closeDropdownMenu(menu) {
  var menuLink = $(menu).data('menuLink');
  menuLink.removeClass('open');
  menu.hide();
  $(document).removeData('openMenuId');
  if (menu.data('isNotificationMenu')) {
    $(document).unbind('click');
  }
}

function closeOpenDropdownMenu() {
  var menu = $(document).data('openMenu');
  if (menu) {
    closeDropdownMenu(menu);
  }
}

function initializeDropdownMenu(menuLinkId, menuDivId, notificationMenuUrl) {
  var menu = $(menuDivId);
  var menuLink = $(menuLinkId);
  menu.data('menuLink', menuLink);
  if (notificationMenuUrl) {
    var countLabel = $('span.count', menuLink);
    menu.data('isNotificationMenu', true);
    menuLink.click(function() {
      var $this = $(this);
      if ($this.hasClass('open')) {
        closeDropdownMenu(menu);
      } else {
        closeOpenDropdownMenu();
        countLabel.hide();
        openDropdownMenu(menu);
        jQuery.ajax({
          type: 'POST',
          url: notificationMenuUrl,
          data: {
            notifications: jQuery.map($('#notification-item', menu), function(item, idx) {return $(item).attr('data')})
          },
          dataType: 'json'
        });
      }
    return false;
    });
  } else {
    menuLink.mouseenter(function() {
      var $this = $(this);
      clearTimeout(dropdownMenuTimeout);
      if (!$this.hasClass('open')) {
        closeOpenDropdownMenu();
        openDropdownMenu(menu);
      }
    });
    menuLink.mouseleave(function() {
      dropdownMenuTimeout = setTimeout(closeOpenDropdownMenu, 500);
    });
    menu.mouseenter(function() {
      clearTimeout(dropdownMenuTimeout);
    });
    menu.mouseleave(function() {
      dropdownMenuTimeout = setTimeout(closeOpenDropdownMenu, 500);
    });
  }
}

$(document).ready(function() {

  //TODO: maybe activate (not yet)?
  //$('#sidebar, #filters').stickySidebar();

  $('#select_all').click(function() {
    var formId = $(this).attr('data-form-selector');
    $('input[type="checkbox"]').prop('checked', true);
    return false;
  });

  $('#select_none').click(function() {
    var formId = $(this).attr('data-form-selector');
    $('input[type="checkbox"]').prop('checked', false);
    return false;
  });

  $.facebox.settings.closeImage   = '/javascripts/vendor/facebox/closelabel.png';
  $.facebox.settings.loadingImage = '/javascripts/vendor/facebox/loading.gif';
  $('a[rel*=facebox]').facebox();

  $('new_charge').submit(function() {
    $('#buck_purchase_bucks_final').val($('#charge_bucks').val());
  });

  // p.alert is hidden
  $('p.notice, p.success, p.error')
    .delay(4800)
    .slideToggle();

  $('#my-activity').click(function() {
    $('ul.activity').toggle();
  });
});
