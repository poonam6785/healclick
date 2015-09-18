class CreateDefaultShopUrl < ActiveRecord::Migration
  def up
  	SystemSetting.get(:shop_url).update_attributes(:value => 'http://www.prohealth.com/search/results.cfm?B1=HEALCLSRC&utm_source=Heal-Click&utm_campaign=Heal-Click-Search-Results&site=products&page=1&start=0&restart=true&searchText=[summaryname]')
  end

  def down
  	
  end
end
