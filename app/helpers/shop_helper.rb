module ShopHelper
  def shop_url_helper(summary)
    return if summary.nil?
    URI.encode SystemSetting.get_value(:shop_url).try(:gsub, /\[summaryname\]/, summary.treatment_name)
  end
end