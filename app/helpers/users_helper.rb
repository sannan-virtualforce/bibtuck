module UsersHelper

  def age_for(user)
    if user.age.present? && !user.hide_age?
      if user.occupation.present?
        "#{user.age} year old #{user.occupation}"
      else
        "#{user.age} years old"
      end
    end
  end

  def age_and_occupation_for(user)
    info = ''
    if user.age.present? && !user.hide_age?
      info << (user.occupation.present? ? "#{user.age} year old " : "#{user.age} years old")
    end
    info << user.occupation if user.occupation.present?
    return info
  end

  def invites_link
    link_to("Invite Friends (#{current_user.invitation_limit.to_s})", new_user_invitation_path)
  end

  def username(user)
    founding =  content_tag(:span, user, :class => "founding_member") do
      '[founding member]'
    end if user.founding_member?
    [user.username, founding].join(' ').html_safe
  end

  def profile_picture(user, size = :preview)
    link_to(image_tag(user.profile_picture.url(size), :alt => user.username), user, :class => 'profile_picture')
  end

  def link_to_user(user)
    link_to user.display_name, user
  end

  def viewing_current_user?
    @user == current_user
  end

  def viewing_user?
    @user.present?
  end

  def show_rating_for(object, should_make_link = true)
    if object.kind_of?(Item)
      return unless object.experience
      r = object.experience.rating.round
      user = object.user
    elsif object.kind_of?(Experience)
      r = object.rating.round
      user = object.user
    elsif object.kind_of?(User)
      return unless object.average_rating
      r = object.average_rating.round
      user = object
    elsif object.kind_of?(Numeric)
      r = object.round
      should_make_link = false
    else
      return
    end

    if should_make_link
      link_to [user, :experiences], :class => 'rating', :title => "Show #{user.username}'s ratings" do 
        0.upto(4) do |i|
          concat(content_tag('div', '', {:class => "rating_triangle#{i < r ? ' filled' : ''}"})) 
        end
      end
    else
      content_tag :div, :class => 'rating' do
        0.upto(4) do |i|
          concat(content_tag('div', '', {:class => "rating_triangle#{i < r ? ' filled' : ''}", :pos => (i + 1)})) 
        end
      end
    end
  end

  def how_did_user_get_to_the_website_txt(user)
    if user.registration_code_id
      'Registration code'
    elsif user.invited_by
      'Invited'
    else
      'Created'
    end
  end

end
