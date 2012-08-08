namespace :validate do

  desc "validate orders"
  task :orders => :environment do
    puts "validating orders ..."
    Order.where(:is_complete => true).includes(:order_items).each do |order|
      unless order.valid?
        puts "  errors for order #{order.id}"
        order.errors.full_messages.each do |msg|
          puts "    > #{msg}"
        end
      end
      order.order_items.each do |order_item|
        unless order_item.valid?
          puts "    errors for order item: #{order_item.id}"
          order_item.errors.full_messages.each do |msg|
            puts "      > #{msg}"
          end
        end
        unless order_item.item.valid?
          puts "    errors for item: #{order_item.item.id}"
          order_item.item.errors.full_messages.each do |msg|
            puts "      > #{msg}"
          end
        end
      end
    end
  end

  desc "validate items"
  task :items => :environment do
    puts "validating items ..."
    Item.all.each do |item|
      unless item.valid?
        puts "  errors for item [#{item.id}] #{item.name}"
        item.errors.full_messages.each do |msg|
          puts "    > #{msg}"
        end
      end
      if item.shipping? || item.complete?
        unless item.order.present?
          puts "  item [#{item.id}] #{item.name} in state #{item.state.titlecase} doesn't have order assigned"
        end
      end
    end
  end
end
