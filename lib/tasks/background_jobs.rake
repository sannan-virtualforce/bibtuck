desc "check for shipping status updates on endicia server"
task :check_shipping_status_updates => :environment do
  OrderItem.where(:shipping_status => [:pending, :shipped]).each do |order_item|
    order_item.check_for_shipping_status_update!
  end
end

desc "notify sellers to ship pending items"
task :notify_sellers_to_ship => :environment do
  OrderItem.where(:shipping_status => :pending).each do |order_item|
    order_item.notify_seller_if_needed
  end
end

desc "remove items from carts that are older than 30 minutes"
task :carts_cleanup => :environment do
  CartItem.destroy_all(["created_at < ?", Cart::CLEANUP_TIMEOUT_MIN.minutes.ago])
end

desc "remove non compleated orders older than 1 day"
task :orders_cleanup => :environment do
  Order.where('is_complete is null and created_at < ?', 1.day.ago).each do |order|
    order.destroy
  end
end

desc "remove unusde pictures older than 60 days"
task :saved_photos_cleanup => :environment do
  # using destroy instead destroy_all so files will be removed from disk also
  Photo.where('item_id is null and created_at < ?', 60.days.ago).each do |photo|
    photo.destroy
  end
end
