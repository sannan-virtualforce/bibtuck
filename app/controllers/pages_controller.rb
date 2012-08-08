class PagesController < HighVoltage::PagesController
  layout :layout_for_page

  protected
  def layout_for_page
    case params[:id]
    when 'no_invite'
      'sessions'
    when 'contact_us',
      'shipping_tips',
      'shipping_and_transaction_info',
      'shipping_from_info',
      'shipping_box_info',
      'community_guidelines',
      'photo_tips'

      'popup'
    else
      'application'
    end
  end
end

