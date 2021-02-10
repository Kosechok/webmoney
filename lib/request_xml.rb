#encoding: utf-8
module Webmoney::RequestXML    # :nodoc:all

  def xml_get_passport(opt)
    Nokogiri::XML::Builder.new { |x|
      x.request {
        x.wmid @wmid if classic?
        x.passportwmid opt[:wmid]
        x.params {
          x.dict opt[:dict] || 0
          x.info opt[:info] || 1
          x.mode opt[:mode] || 0
        }
        # unless mode == 1, signed data need'nt, but elem <sign/> required
        x.sign( (classic? && opt[:mode]) ? sign(@wmid+opt[:wmid]) : nil ) if classic?
      }
    }
  end

  def xml_bussines_level(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('WMIDLevel.request') {
        x.signerwmid @wmid
        x.wmid opt[:wmid]
      }
    }
  end

  def xml_trust_level(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('trustlimits') {
        x.getlevels {
          x.signerwmid @wmid
          x.wmid opt[:wmid]
        }
      }
    }
  end

  def xml_check_sign(opt)
    plan_in, plan_out = filter_str(opt[:plan])
    Nokogiri::XML::Builder.new( :encoding => 'windows-1251' ) { |x|
      x.send('w3s.request') {
        x.wmid @wmid
        x.testsign {
          x.wmid opt[:wmid]
          x.plan { x.cdata plan_in }
          x.sign opt[:sign]
        }
        x.sign sign("#{@wmid}#{opt[:wmid]}#{plan_out}#{opt[:sign]}") if classic?
      }
    }
  end

  def xml_send_message(opt)
    req = reqn()
    text_in, text_out = filter_str(opt[:text])
    Nokogiri::XML::Builder.new( :encoding => 'windows-1251' ) { |x|
      x.send('w3s.request') {
        x.wmid @wmid
        x.reqn req
        x.message do
          x.receiverwmid opt[:wmid]
          x.msgtext { x.cdata text_in }
        end
        x.sign sign("#{opt[:wmid]}#{req}#{text_out}") if classic?
      }
    }
  end

  def xml_find_wm(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
      x.send('w3s.request') {
        x.wmid @wmid
        x.reqn req
        x.testwmpurse do
          x.wmid( opt[:by_wmid] || '' )
          x.purse( opt[:by_purse] || '' )
        end
        x.sign sign("#{opt[:by_wmid]}#{opt[:by_purse]}") if classic?
      }
    }
  end

  def xml_create_invoice(opt)
    req = reqn()
    desc_in, desc_out = filter_str(opt[:desc])
    address_in, address_out = filter_str(opt[:address])
    amount = opt[:amount].to_f.to_s.gsub(/\.?0+$/, '')
    Nokogiri::XML::Builder.new( :encoding => 'windows-1251' ) { |x|
      x.send('w3s.request') {
        x.reqn req
        x.wmid @wmid
        x.sign sign("#{opt[:orderid]}#{opt[:customerwmid]}#{opt[:storepurse]}#{amount}#{desc_out}#{address_out}#{opt[:period]||0}#{opt[:expiration]||0}#{req}") if classic?
        x.invoice do
          x.orderid opt[:orderid]
          x.customerwmid opt[:customerwmid]
          x.storepurse opt[:storepurse]
          x.amount amount
          x.desc desc_in
          x.address address_in
          x.period opt[:period].to_i
          x.expiration opt[:expiration].to_i
        end
      }
    }
  end

  def xml_create_transaction(opt)
    req = reqn()
    desc_in, desc_out = filter_str(opt[:desc])                  # description
    pcode = opt[:pcode].strip if opt.has_key?(:period) && opt[:period] > 0 && opt[:pcode]
    Nokogiri::XML::Builder.new( :encoding => 'windows-1251' ) { |x|
      x.send('w3s.request') {
        x.reqn req
        x.wmid(@wmid)
        x.sign sign("#{req}#{opt[:transid]}#{opt[:pursesrc]}#{opt[:pursedest]}#{opt[:amount]}#{opt[:period]||0}#{pcode}#{desc_out}#{opt[:wminvid]||0}") if classic?
        x.trans {
          x.tranid opt[:transid]                      # transaction id - unique
          x.pursesrc opt[:pursesrc]                   # sender purse
          x.pursedest opt[:pursedest]                 # recipient purse
          x.amount opt[:amount]
          x.period( opt[:period] || 0 )                # protection period (0 - no protection)
          x.pcode( pcode ) if pcode  # protection code
          x.desc desc_in
          x.wminvid( opt[:wminvid] || 0 )              # invoice number (0 - without invoice)
          x.onlyauth( 1 )                              # IMPORTANT!! only for user's who allow!
        }
      }
    }
  end

  def xml_outgoing_invoices(opt)
    req = reqn()
    Nokogiri::XML::Builder.new( :encoding => 'windows-1251' ) { |x|
      x.send('w3s.request') {
        x.reqn req
        x.wmid @wmid
        x.sign sign("#{opt[:purse]}#{req}") if classic?
        x.getoutinvoices do
          x.purse opt[:purse]
          x.wminvid opt[:wminvid]
          x.orderid opt[:orderid]
          x.datestart Date.parse(opt[:datestart]).strftime("%Y%m%d %H:%M:%S")
          x.datefinish Date.parse(opt[:datefinish]).strftime("%Y%m%d %H:%M:%S")
        end
      }
    }
  end

  def xml_login(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('request') {
        x.siteHolder opt[:siteHolder] || @wmid
        x.user opt[:WmLogin_WMID]
        x.ticket opt[:WmLogin_Ticket]
        x.urlId  opt[:WmLogin_UrlID]
        x.authType opt[:WmLogin_AuthType]
        x.userAddress opt[:remote_ip]
      }
    }
  end

  def xml_i_trust(opt)
    opt[:wmid] = @wmid
    xml_trust_me(opt)
  end

  def xml_trust_me(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
      x.send('w3s.request') {
        x.reqn req
        x.wmid @wmid
        x.sign sign("#{opt[:wmid]}#{req}") if classic?
        x.gettrustlist do
          x.wmid opt[:wmid]
        end
      }
    }
  end

  def xml_trust_save(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
      x.send('w3s.request') {
        x.reqn req
        x.wmid @wmid
        x.sign sign("#{opt[:wmid]}#{opt[:purse]}#{opt[:masterwmid]}#{req}") if classic?
        x.trust(inv: opt[:send_invoice] || 0, trans: opt[:send_transaction] || 0, purse: opt[:get_purses] || 0, transhist: opt[:get_history] || 0)  do
          x.masterwmid opt[:masterwmid]
          x.slavewmid @wmid
          x.purse opt[:purse]
          x.limit opt[:limit]
          x.daylimit opt[:daylimit]
          x.weeklimit opt[:weeklimit]
          x.monthlimit opt[:monthlimit]
        end
      }
    }
  end

  def xml_transaction_get(opt)
    Nokogiri::XML::Builder.new{ |x|
      x.send('merchant.request') {
        x.wmid opt[:wmid]
        x.lmi_payee_purse opt[:payee_purse]
        x.lmi_payment_no opt[:orderid]
        x.lmi_payment_no_type opt[:paymenttype]
        x.sign sign("#{opt[:wmid]}#{opt[:payee_purse]}#{opt[:orderid]}")
      }
    }
  end

  def xml_check_user(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
      x.send('passport.request') {
        x.reqn req
        x.signerwmid @wmid
        x.sign sign("#{req}#{opt[:operation][:type]}#{opt[:userinfo][:wmid]}") if classic?
        x.operation do
          opt[:operation].each do |operation_key, operation_value|
            operation_key = "#{operation_key}_" if operation_key.to_sym == :type
            x.send(operation_key, operation_value)
          end
        end
        x.userinfo do
          opt[:userinfo].each do |userinfo_key, userinfo_value|
            x.send(userinfo_key, userinfo_value)
          end
        end
      }
    }
  end

  def xml_balance(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
      x.send('w3s.request') {
        x.reqn req
        x.wmid @wmid
        x.sign sign("#{opt[:wmid]}#{req}") if classic?
        x.getpurses do
          x.wmid opt[:wmid]
        end
      }
    }
  end

  def xml_req_payment(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
      x.send('merchant.request'){
        x.lmi_payment_no opt[:paymentid]
        x.wmid opt[:wmid]
        x.lmi_payee_purse opt[:purse]
        x.lmi_payment_amount opt[:amount]
        x.lmi_payment_desc opt[:description]
        x.lmi_clientnumber opt[:clientid]
        x.lmi_clientnumber_type opt[:clientidtype]
        x.lmi_hold opt[:hold_days] || nil
        x.lmi_sms_type opt[:smstype]
        x.lang opt[:lang] || 'en-US'
        x.emulated_flag opt[:emulated_flag] || 0
        x.sign sign("#{opt[:wmid]}#{opt[:purse]}#{opt[:paymentid]}#{opt[:clientid]}#{opt[:clientidtype]}")
      }
    }
  end

  def xml_conf_payment(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('merchant.request'){
        x.wmid opt[:wmid]
        x.lmi_payee_purse opt[:purse]
        x.lmi_clientnumber_code opt[:paymentcode]
        x.lmi_wminvoiceid opt[:invoiceid]
        x.sign sign("#{opt[:wmid]}#{opt[:purse]}#{opt[:invoiceid]}#{opt[:paymentcode]}")
      }
    }
  end

  def xml_operation_history(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
        x.send('w3s.request'){
            x.reqn req
            x.wmid opt[:wmid] if classic?
            x.sign sign("#{opt[:purse]}#{req}") if classic?
            x.getoperations do
                x.purse opt[:purse]
                x.wmtranid opt[:wmtranid] || 0
                x.tranid opt[:tranid] || 0
                x.wminvid opt[:wminvid] || 0
                x.orderid opt[:orderid] || 0
                x.datestart DateTime.parse(opt[:datestart]).strftime("%Y%m%d %H:%M:%S")
                x.datefinish DateTime.parse(opt[:datefinish]).strftime("%Y%m%d %H:%M:%S")
            end
        }
    }
  end

  def xml_set_trust(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('merchant.request'){
        x.wmid opt[:wmid]
        x.lmi_payee_purse opt[:purse]
        x.lmi_day_limit opt[:day_limit]
        x.lmi_week_limit opt[:week_limit]
        x.lmi_month_limit opt[:month_limit]
        x.lmi_clientnumber opt[:client_number]
        x.lmi_clientnumber_type opt[:client_number_type]
        x.lmi_sms_type opt[:sms_type]
        x.sign sign("#{opt[:wmid]}#{opt[:purse]}#{opt[:client_number]}#{opt[:client_number_type]}#{opt[:sms_type]}")
        x.lang opt[:lang]
      }
    }
  end

  def xml_confirm_trust(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('merchant.request'){
        x.wmid opt[:wmid]
        x.lmi_purseid opt[:purseid]
        x.lmi_clientnumber_code opt[:clientnumber_code]
        x.sign sign("#{opt[:wmid]}#{opt[:purseid]}#{opt[:clientnumber_code]}")
        x.lang opt[:lang]
      }
    }
  end

  def xml_merchant_token(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('merchant.request'){
        x.signtags do
          x.validityperiodinhours opt[:hours]
          x.wmid opt[:wmid]
          x.sign sign("#{opt[:wmid]}#{opt[:purse]}#{opt[:paymentid]}#{opt[:hours]}")
        end
        x.paymenttags do
          x.lmi_payee_purse opt[:purse]
          x.lmi_payment_no opt[:paymentid]
          x.lmi_payment_amount opt[:amount]
          x.lmi_payment_desc opt[:description]
          unless opt[:user_params].nil?
            opt[:user_params].each do |key, val|
              x.key val
            end
          end
        end
      }
    }
  end

  def xml_transaction_moneyback(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
      x.send('w3s.request') {
        x.reqn req
        x.wmid @wmid
        x.sign sign("#{req}#{opt[:tranid]}#{opt[:amount]}") if classic?
        x.trans do
          x.inwmtranid opt[:tranid]
          x.amount opt[:amount]
          x.wmb_denomination 1
        end
      }
    }
  end

  def xml_exchanger_tender_place(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.wmid opt[:wmid] if classic?
        x.signstr sign("#{opt[:wmid]}#{opt[:inpurse]}#{opt[:outpurse]}#{opt[:inamount]}#{opt[:outamount]}") if classic?
        x.inpurse opt[:inpurse]
        x.outpurse opt[:outpurse]
        x.inamount opt[:inamount]
        x.outamount opt[:outamount]
        x.capitallerwmid opt[:capitallerwmid] || 0
      }
    }
  end

  def xml_exchanger_tender_change_rate(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.wmid opt[:wmid] if classic?
        x.signstr sign("#{opt[:wmid]}#{opt[:operid]}#{opt[:curstype]}#{opt[:cursamount]}") if classic?
        x.operid opt[:operid]
        x.curstype opt[:curstype]
        x.cursamount opt[:cursamount]
        x.capitallerwmid opt[:capitallerwmid] || 0
      }
    }
  end

  def xml_exchanger_my_tenders(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.wmid opt[:wmid]
        x.signstr sign("#{opt[:wmid]}#{opt[:type] || 1}#{opt[:queryid]}") if classic?
        x.type opt[:type] || 1
        x.pursetype_id opt[:pursetype_id] unless opt[:pursetype_id].nil?
        x.queryid opt[:queryid] unless opt[:queryid].nil?
        x.capitallerwmid opt[:capitallerwmid] || 0
      }
    }
  end

  def xml_exchanger_my_counter_tenders(opt)
     Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.wmid opt[:wmid]
        x.signstr sign("#{opt[:wmid]}#{opt[:type] || 1}#{opt[:queryid] || "-1"}") if classic?
        x.type opt[:type] || 1
        x.queryid opt[:queryid] || "-1"
        x.capitallerwmid opt[:capitallerwmid] || 0
      }
    }
  end

  def xml_exchanger_my_tender_counters(opt)
     Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.wmid opt[:wmid]
        x.signstr sign("#{opt[:wmid]}#{opt[:queryid] || "-1"}") if classic?
        x.queryid opt[:queryid]
        x.capitallerwmid opt[:capitallerwmid] || 0
      }
    }
  end
=begin
  def xml_exchanger_current_tenders(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.exchtype opt[:type]
      }
    }
  end
=end

  def xml_exchanger_tender_devide(opt)
     Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.wmid opt[:wmid]
        x.signstr sign("#{opt[:wmid]}#{opt[:operid]}#{opt[:exchtype]}#{opt[:outpurse]}#{opt[:inamount]}#{opt[:outamount]}") if classic?
        x.operid opt[:operid]
        x.exchtype opt[:exchtype]
        x.outpurse opt[:outpurse]
        x.inamount opt[:inamount]
        x.outamount opt[:outamount]
        x.capitallerwmid opt[:capitallerwmid] || 0
      }
    }
  end


  def xml_exchanger_tenders_union(opt)
     Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.wmid opt[:wmid]
        x.signstr sign("#{opt[:wmid]}#{opt[:operid]}#{opt[:union_id]}") if classic?
        x.operid opt[:operid]
        x.unionoperid opt[:union_id]
        x.capitallerwmid opt[:capitallerwmid] || 0
      }
    }
  end

  def xml_exchanger_wmid_balance(opt)
    req = reqn()
    Nokogiri::XML::Builder.new { |x|
      x.send('wm.exchanger.request'){
        x.reqn req
        x.wmid opt[:wmid]
        x.signstr sign("#{opt[:wmid]}#{opt[:operid]}#{opt[:capitallerwmid]}#{req}") if classic?
        x.capitallerwmid opt[:capitallerwmid] || 0
      }
    }
  end

  def xml_debt_new_line(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    # pass = ""
    Nokogiri::XML::Builder.new { |x|
      x.send('service.request'){
        x.wmid          @wmid
        x.t             timestamp
	puts "#{@wmid}:#{opt[:for_wmid]}:#{opt[:purse]}:#{opt[:amount]}:#{opt[:period]}:#{opt[:periodicity]}:#{opt[:percent]}:#{opt[:timelife]}:#{timestamp}:#{@debt_pass}"
        x.sign          sign("#{@wmid}:#{opt[:for_wmid]}:#{opt[:purse]}:#{opt[:amount]}:#{opt[:period]}:#{opt[:periodicity]}:#{opt[:percent]}:#{opt[:timelife]}:#{timestamp}:#{@debt_pass}")
        x.creditline  do
          x.forwmid         opt[:for_wmid]
          x.purse           opt[:purse]
          x.amount          opt[:amount]
          x.period          opt[:period]
          x.proc            opt[:percent]
          x.periodicity     opt[:periodicity]
          x.timelife        opt[:timelife]
        end
      }
    }
  end

  def xml_debt_credit_lines(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    Nokogiri::XML::Builder.new { |x|
      x.send('service.request'){
        x.wmid          @wmid
        x.t             timestamp
        x.sign          Digest::SHA1.hexdigest "#{@wmid}:#{timestamp}:#{@debt_pass}"
      }
    }
  end

  def xml_debt_block_user(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    # pass = ""
    Nokogiri::XML::Builder.new { |x|
      x.send('service.request'){
        x.wmid          @wmid
        x.t             timestamp
        x.creditid      opt[:credit_id], block: opt[:block]
        x.sign          Digest::SHA1.hexdigest "#{@wmid}:#{timestamp}:#{opt[:credit_id]}:#{opt[:block]}:#{@debt_pass}"
      }
    }
  end

  def xml_debt_return_loan(opt)
    timestamp = DateTime.now.strftime("%Q").to_sym
    # pass = ""
    Nokogiri::XML::Builder.new { |x|
      x.send('service.request'){
        x.wmid          @wmid
        x.t             timestamp
        x.creditid      opt[:credit_id], before: opt[:before]
        x.sign          Digest::SHA1.hexdigest "#{@wmid}:#{timestamp}:#{opt[:credit_id]}:#{opt[:before]}:#{@debt_pass}"
      }
    }
  end

  def xml_debt_credits_list(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('service.request'){
        x.wmid          @wmid
        x.from          Date.parse(opt[:datestart]).strftime("%Y-%m-%dT%H:%M:%S")
        x.to            Date.parse(opt[:datefinish]).strftime("%Y-%m-%dT%H:%M:%S")
        x.sign          Digest::SHA1.hexdigest "#{@wmid}:#{Date.parse(opt[:datestart]).strftime("%Y-%m-%dT%H:%M:%S")}:#{Date.parse(opt[:datefinish]).strftime("%Y-%m-%dT%H:%M:%S")}:#{@debt_pass}"
      }
    }
  end

  def xml_debt_credit_details(opt)
    Nokogiri::XML::Builder.new { |x|
      x.send('service.request'){
        x.wmid          @wmid
        x.creditid      opt[:credit_id]
        x.sign          Digest::SHA1.hexdigest "#{@wmid}:#{opt[:credit_id]}:#{@debt_pass}"
      }
    }
  end
end
