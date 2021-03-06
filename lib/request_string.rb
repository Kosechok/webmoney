#encoding: utf-8
module Webmoney::RequestString    # :nodoc:all

  def hash_credit_list(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    params = {
      :wmid => @wmid,
      :tid  => opt[:tid] || 0,
      :t    => timestamp,
      :out  => "xml",
      :SS   => sign("#{opt[:wmid]};#{opt[:tid] || 0};#{timestamp}")
    }    
  end

  def hash_credit_bid(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    params = {
      wmid: @wmid,
      tid:  opt[:tid],
      a:    '%.2f' % opt[:amount],    
      p:    opt[:purse],
      t:    timestamp,
      out:  "xml",
      :SS => sign("#{@wmid};#{opt[:tid]};#{'%.2f' % opt[:amount]};#{opt[:purse]};#{timestamp}") 
    }
  end

  def hash_credit_bids_list(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    params = {
      wmid: @wmid,
      tid:  opt[:tid] || 0,
      t:    timestamp,
      out:  "xml",
      :SS => sign("#{@wmid};#{opt[:tid] || 0};#{timestamp}") 
    }
    params[:VR] = 1 if opt[:reversed]
    params[:VD] = 1 if opt[:deleted]
    return params
  end

  def hash_credit_bid_del(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    params = {
      wmid: @wmid,
      tid:  opt[:tid],
      t:    timestamp,
      out:  "xml",
      :SS => sign("#{@wmid};#{opt[:tid]};#{timestamp}") 
    }
  end

  def hash_credit_borrower_tenders(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    params = {
      wmid: @wmid, 
      t:    timestamp,
      bwmid: opt[:borrower_wmid],
      out:  "xml",
      :SS => sign("#{@wmid};#{opt[:borrower_wmid]};#{timestamp}")      
    }

  end

  def hash_exchanger_current_tenders(opt)
    params = {
      exchtype: opt[:type]
    }      
  end

   
end
