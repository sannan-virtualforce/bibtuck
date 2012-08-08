class NotificationsController < ApplicationController
  include ApplicationHelper
  include NotificationsHelper

  # GET /notifications
  def index
    current_user.notifications.unread.each(&:view!)
    current_user.reload
    @notifications = current_user.notifications.sorted
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /notifications/1
  # GET /notifications/1.xml
  def show
    @notification = current_user.notifications.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notification }
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.json
  def update
    @notification = current_user.notifications.find(params[:id])

    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        format.html { redirect_to(notifications_path,
                      :notice => 'Notification was successfully updated.') }
        format.json  {
          notification = current_user.notifications.unread.sorted.first
          if notification
            render :json => {
              :notification => notification_text(notification),
              :action       => notification_url(notification),
              :count        => current_user.notifications.unread.count
            }
          else
            render :json => { :count => 0 }
          end
        }
      else
        format.html { render :action => "edit" }
        format.json  { render :json   => @notification.errors,
                              :status => :unprocessable_entity }
      end
    end
  end

  def mark_as_read
    notification_list = params[:notifications]
    notification_list.each do |notification_id|
      notification = current_user.notifications.find(notification_id)
      notification.touch(:viewed_at) if notification
    end
    render :json => { :count => current_user.notifications(true).unread.count }
  end
end
