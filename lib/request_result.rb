#encoding: utf-8
module Webmoney::RequestResult    # :nodoc:all

  def result_check_sign(doc)
    doc.at('//testsign/res').inner_html == 'yes' ? true : false
  end

  def result_get_passport(doc)
    Webmoney::Passport.parse_result(doc)
  end

  def result_get_country(doc)
    {
      retval: doc.at('//retval').inner_html.to_i,
      country_id: doc.at('//data/row')['countryid'],
      country_name: doc.at('//data/row')['countryname']
    }
  end

  def result_bussines_level(doc)
    doc.at('//level').inner_html.to_i
  end

  def result_trust_level(doc)
    doc.at('//tl')['val'].to_i
  end

  def result_send_message(doc)
    {
      :id => doc.at('//message')['id'],
      :date => Time.parse(doc.at('//message/datecrt').inner_html)
    }
  end

  def result_find_wm(doc)
    {
      :retval => doc.at('//retval').inner_html.to_i,
      :wmid   => (doc.at('//testwmpurse/wmid').inner_html rescue nil),
      :purse  => (doc.at('//testwmpurse/purse').inner_html rescue nil)
    }
  end

  def result_create_invoice(doc)
    res = {
      :retval => doc.at('//retval').inner_html.to_i,
      :retdesc   => (doc.at('//testwmpurse/retdesc').inner_html rescue nil),
      :orderid  => doc.at('//invoice/orderid').inner_html.to_i
    }
    if res[:retval] == 0
      res[:id]  = doc.at('//invoice')['id'].to_i
      res[:ts]  = doc.at('//invoice')['ts'].to_i
      res[:state] = doc.at('//invoice/state').inner_html.to_i
      res[:created_at] = Time.parse(doc.at('//invoice/datecrt').inner_html)
    end
    res
  end

  def result_create_transaction(doc)
    op = doc.at('//operation')
    {
      :operation_id => op['id'],
      :operation_ts => op['ts']
    }.merge( op.children.inject({}) do |memo, elm|
      memo.merge!(elm.name.to_sym => elm.text)
    end )
  end

  def result_outgoing_invoices(doc)
    res = {
      :retval => doc.at('//retval').inner_html.to_i,
      :retdesc   => (doc.at('//testwmpurse/retdesc').inner_html rescue nil),
    }
    res[:invoices] = doc.xpath('//outinvoices/outinvoice').map do |invoice|
      r = {
        :id => invoice['id'].to_i,
        :ts => invoice['ts'].to_i,
      }
      invoice.elements.each do |tag|
        name = tag.name.to_sym
        value = tag.inner_html
        value = value.to_i if [:orderid, :tranid, :period, :expiration, :wmtranid, :state].include?(name)
        value = value.to_f if [:rest, :amount, :comiss].include?(name)
        value = Time.parse(value) if [:datecrt, :dateupd].include?(name)
        value = cp1251_to_utf8(value) if [:desc, :address].include?(name)
        r[name] = value
      end
      r
    end
    res
  end

  def result_login(doc)
    {
      :retval => doc.at('/response')['retval'].to_i,
      :retdesc   => doc.at('/response')['sval'],
      :lastAccess => doc.at('/response')['lastAccess'],
      :expires => doc.at('/response')['expires']
    }
  end

  def result_trust_me(doc)
    {
      :count        => doc.at('//trustlist')['cnt'].to_i,
      :invoices     => doc.xpath('//trust[@inv="1"]/purse').map(&:inner_text),
      :transactions => doc.xpath('//trust[@trans="1"]/purse').map(&:inner_text),
      :balance      => doc.xpath('//trust[@purse="1"]/purse').map(&:inner_text),
      :history      => doc.xpath('//trust[@transhist="1"]/purse').map(&:inner_text)
    }
  end

  def result_trust_save(doc)
    {
      :retval => doc.at('//retval').inner_html,
      :retdesc => doc.at('//retdesc').inner_html,
      :id => doc.at('//trust')['id'].to_i,
      :inv => doc.at('//trust')['inv'].to_i,
      :trans => doc.at('//trust')['trans'].to_i,
      :purse_balance => doc.at('//trust')['purse '].to_i,
      :trans_history => doc.at('//trust')['transhist'].to_i,
      :purse => doc.at('//trust/purse'),
      :master => doc.at('//trust/master')
    }
  end

  def result_transaction_get(doc)
    if doc.at('//operation')
      wminvoiceid = doc.at('//operation')['wminvoiceid'].to_i
      wmtransid = doc.at('//operation')['wmtransid'].to_i
      enumflag = doc.at('//operation/enumflag').inner_html.to_i if doc.at('//operation/enumflag')
      amount = doc.at('//operation/amount').inner_html.to_f
      operdate = Time.parse(doc.at('//operation/operdate').inner_html)
      pursefrom = doc.at('//operation/pursefrom').inner_html
      wmidfrom = doc.at('//operation/wmidfrom').inner_html
      capitallerflag = doc.at('//operation/capitallerflag').inner_html.to_i
      ip = doc.at('//operation/IPAddress').inner_html
      phone = doc.at('//operation/telepat_phone').inner_html if doc.at('//operation/telepat_phone')
      telepat_paytype = doc.at('//operation/telepat_paytype').inner_html.to_i
      payment_number = doc.at('//operation/paymer_number').inner_html
      paymer_type = doc.at('//operation/paymer_type').inner_html.to_i
      {
          :retval => doc.at('//retval').inner_html,
          :retdesc => doc.at('//retdesc').inner_html,
          :wminvoiceid => wminvoiceid,
          :wmtransid => wmtransid,
          :amount => amount,
          :operdate => operdate,
          :pursefrom => pursefrom,
          :wmidfrom => wmidfrom,
          :capitallerflag => capitallerflag,
          :enumflag => enumflag.to_i,
          :IPAddress => ip,
          :telepat_phone => phone,
          :telepat_paytype => telepat_paytype,
          :paymer_number => payment_number,
          :paymer_type => paymer_type
      }
    else
      {
          :retval => doc.at('//retval').inner_html,
          :retdesc => doc.at('//retdesc').inner_html
      }
    end
  end

  def result_req_payment(doc)
    {
        :wminvoiceid  => doc.at('//operation')['wminvoiceid'].to_i,
        :realsmstype  => doc.at('//operation')['realsmstype'].to_i,
        :retval       => doc.at('//retval').inner_html.to_i,
        :retdesc      => doc.at('//retdesc').inner_html,
        :userdesc      => doc.at('//userdesc').inner_html
    }
  end

  def result_conf_payment(doc)
    if doc.at('//smssentstate').nil? || doc.at('//smssentstate').blank?
      smsstate = nil
    else
      smsstate = doc.at('//smssentstate').inner_html
    end
    {
        :wminvoiceid    => doc.at('//operation')['wminvoiceid'].to_i,
        :wmtransid      => doc.at('//operation')['wmtransid'].to_i,
        :amount         => doc.at('//operation/amount').inner_html.to_f,
        :operdate       => Time.parse(doc.at('//operation/operdate').inner_html),
        :pursefrom      => doc.at('//operation/pursefrom').inner_html,
        :wmidfrom       => doc.at('//operation/wmidfrom').inner_html,
        :retval         => doc.at('//retval').inner_html.to_i,
        :retdesc        => doc.at('//retdesc').inner_html,
        :smssentstate   => smsstate
    }
  end

  alias_method :result_i_trust, :result_trust_me

  def result_check_user(doc)
    {
      :retval => doc.at('//retval').inner_html.to_i
    }
  end

  def result_balance(doc)
    purses = []
    doc.at('//purses').children.each do |purse|
      purses_hash = {}
      purse.children.each do |child|
        purses_hash[child.name.to_sym] = child.content
      end
      purses << purses_hash unless purses_hash.empty?
    end
    {
      :purses => purses,
      :retval => doc.at('//retval').inner_html.to_i
    }
  end

  def result_operation_history(doc)
    operations = []
    doc.at('//operations').children.each do |operation|
        operations_hash = {}
        operation.attributes.each do |attr|
          operations_hash[attr[1].name.to_sym] = attr[1].value
        end
        operation.children.each do |child|
            operations_hash[child.name.to_sym] = child.content
        end
        operations << operations_hash unless operations_hash.empty?
    end
    {
        :operations => operations,
        :retval => doc.at('//retval').inner_html.to_i
    }
  end

  def result_set_trust(doc)
    {
      :trustpurseid => doc.at('//trust')['purseid'].to_i,
      :smssecureid => doc.at("//smssecureid").inner_html.to_s
    }
  end

  def result_confirm_trust(doc)
    # puts doc
    # Rails.logger.info doc
    {
        :trustid => doc.at('//trust')['id'].to_i,
        :slavepurse => doc.at('//trust/slavepurse').inner_html.to_s,
        :slavewmid => doc.at('//trust/slavewmid').inner_html.to_s
    }
  end

  def result_cancel_invoice(doc)
    {
        invoice_id: doc.at('//ininvoice')['id'].to_i,
        state: doc.at('//ininvoice/state').inner_html.to_i,
        update: doc.at('//ininvoice/dateupd').inner_html.to_s
    }
  end
  alias_method :result_i_trust, :result_trust_me

  def result_merchant_token(doc)
    {
      hours: doc.at('//validityperiodinhours').inner_html.to_i,
      token: doc.at('//transtoken').inner_html.to_s
    }
  end


  def tender_helper(doc)
    my_tender = {}
    doc.at('ztenderData').attributes.each do |attr|
      my_tender[attr[1].name.underscore.to_sym] = attr[1].value
    end
    doc.at('ztenderData').children.each do |tender|
      my_tender[tender.name.underscore.to_sym] = tender.content
    end
    return my_tender
  end

  def result_credit_bid(doc)
    {
      :tender => tender_helper(doc),
      :retval => doc.at('//retval').inner_html.to_i
    }
  end

  def ctenders_helper(doc)
    ctenders = []
    doc.at('//ctenders').children.each do |ctender_list|
        tender_hash = {}
        tender_hash[:tender_id] = ctender_list.at('ctenderData').attributes['TenderID'].value
        ctender_list.at('ctenderData').children.each do |child|
            tender_hash[child.name.underscore.to_sym] = child.content
        end
        tender_hash[:credit_status] = Hash.new
        ctender_list.at('CreditStatus').children.each do |child|
            tender_hash[:credit_status][child.name.underscore.to_sym] = child.content
        end
        tender_hash[:att_data] = Hash.new
        ctender_list.at('AttData').children.each do |child|
            tender_hash[:att_data][child.name.underscore.to_sym] = child.content
        end
        if doc.at('//ztenders')
          if doc.at('//ztenders').attributes['cnt'].value.to_i > 0
              my_tenders = []
              doc.at('//ztenders').children.each do |child|

                  my_tenders << tender_helper(child)
              end
              tender_hash[:ztenders] = my_tenders
          end
        end
        ctenders << tender_hash unless tender_hash.empty?

    end
  end

  def result_credit_list(doc)

    ctenders = []
    doc.at('//ctenders').children.each do |ctender_list|
        tender_hash = {}
        tender_hash[:tender_id] = ctender_list.at('ctenderData').attributes['TenderID'].value
        ctender_list.at('ctenderData').children.each do |child|
            tender_hash[child.name.underscore.to_sym] = child.content
        end
        tender_hash[:credit_status] = Hash.new
        ctender_list.at('CreditStatus').children.each do |child|
            tender_hash[:credit_status][child.name.underscore.to_sym] = child.content
        end
        tender_hash[:att_data] = Hash.new
        ctender_list.at('AttData').children.each do |child|
            tender_hash[:att_data][child.name.underscore.to_sym] = child.content
        end
        if doc.at('//ztenders')
          if doc.at('//ztenders').attributes['cnt'].value.to_i > 0
              my_tenders = []
              doc.at('//ztenders').children.each do |child|

                  my_tenders << tender_helper(child)
              end
              tender_hash[:ztenders] = my_tenders
          end
        end
        ctenders << tender_hash unless tender_hash.empty?

    end

    {
        :ctenders => ctenders,
#        :ctenders => ctenders_helper(doc),
        :retval => doc.at('//retval').inner_html.to_i
    }
  end

  def result_credit_bids_list(doc)
    my_tenders = []
    doc.at('//ztenders').children.each do |child|
      my_tenders << tender_helper(child)
    end
    {
      :tenders => my_tenders,
      :retval => doc.at('//retval').inner_html.to_i
    }
  end

  def result_credit_bid_del(doc)
    {
      :tender => tender_helper(doc),
      :retval => doc.at('//retval').inner_html.to_i
    }
  end

  def result_credit_borrower_tenders(doc)
    {
      :retval => doc.at('//retval').inner_html.to_i
    }
  end

  def result_exchanger_tender_place(doc)
    {
      retval: doc.at('//retval').inner_html.to_i,
      operid: doc.at('//retval')['operid'].to_i,
      wmtransid: doc.at('//retval')['operid'].to_i
    }
  end

  def result_exchanger_tender_change_rate(doc)
    {
      retval: doc.at('//retval').inner_html.to_i,
      amount_rest_in: doc.at('//AmountRestIn').inner_html.gsub(',', '.').to_f,
      amount_rest_out: doc.at('//AmountRestOut').inner_html.gsub(',', '.').to_f
    }
  end
=begin
  def exchanger_tender_helper(doc)
    {
      id: doc.at('//query')['id'].to_i,
      exchtype: doc.at('//query')['exchtype'].to_i,
      state: doc.at('//query')['state'].to_i,
      amountin: doc.at('//query')['amountin'].gsub(',', '.').to_f,
      amountout: doc.at('//query')['amountout'].gsub(',', '.').to_f,
      inoutrate: doc.at('//query')['inoutrate'].gsub(',', '.').to_f,
      outinrate: doc.at('//query')['outinrate'].gsub(',', '.').to_f,
      inpurse: doc.at('//query')['inpurse'],
      outpurse: doc.at('//query')['outpurse'],
      querydatecr: DateTime.parse(doc.at('//query')['querydatecr']),
      querydate: DateTime.parse(doc.at('//query')['querydate']),
      direction: doc.at('//query')['direction'],
      exchamountin: doc.at('//query')['exchamountin'].gsub(',', '.').to_f,
      exchamountout: doc.at('//query')['exchamountout'].gsub(',', '.').to_f
    }
  end
=end
  def result_exchanger_my_tenders(doc)
    my_queries = []
    doc.at('//WMExchnagerQuerys').children.each do |query|
      query_hash = {}
      query.attributes.each do |attr|
        query_hash[attr[1].name.to_sym] = attr[1].value
      end
      my_queries << query_hash
    end
    {
      wmid: doc.at('//WMExchnagerQuerys')['wmid'],
      retval: doc.at('//retval').inner_html.to_i,
      tenders: my_queries
    }
  end

  def result_exchanger_current_tenders(doc)
    queries = []
    doc.at('//WMExchnagerQuerys').children.each do |query|
      query_hash = {}
      query.attributes.each do |attr|
        query_hash[attr[1].name.to_sym] = attr[1].value
      end
      queries << query_hash
    end
    {
      direction_banl_rate: doc.at('//BankRate')['direction'],
      bank_rate: doc.at('//BankRate').inner_html.gsub(',', '.').to_f,
      queries_direction: doc.at('//WMExchnagerQuerys')['inoutrate'],
      queries: queries
    }
  end

  def result_exchanger_my_counter_tenders(doc)
    my_queries = []
    doc.at('//WMExchnagerQuerys').children.each do |query|
      query_hash = {}
      query.attributes.each do |attr|
        query_hash[attr[1].name.to_sym] = attr[1].value
      end
      my_queries << query_hash
    end
    {
      wmid: doc.at('//WMExchnagerQuerys')['wmid'],
      retval: doc.at('//retval').inner_html.to_i,
      tenders: my_queries
    }
  end

  def result_exchanger_tender_devide(doc)

  end

  def result_exchanger_tenders_union(doc)

  end

  def result_exchanger_my_tender_counters(doc)

  end

  def result_exchanger_wmid_balance(doc)

  end

  def result_indx_balance(doc)

  end

  def result_debt_block_user(doc)
    {
      :retval => doc.at('//retval').inner_html,
      :retdesc => doc.at('//retdesc').inner_html,
      block: doc.at('//wmid')['block'],
      wmid: doc.at('//wmid')
    }
  end

  def result_debt_credit_lines(doc)
    my_credit_lines = []
    doc.at('creditlines').children.each do |credit_line|
      credit_hash = {}
      credit_line.attributes.each do |attr|
        credit_hash[attr[1].name.to_sym] = attr[1].value

      end
      credit_line.children.each do |child|
        credit_hash[child.name.to_sym] = child.content
      end

      my_credit_lines << credit_hash unless credit_hash.empty?
    end
    {
      credit_lines: my_credit_lines,
      retval: doc.at('//retval').inner_html

    }
  end

  def result_debt_return_loan(doc)
    {
      :retval => doc.at('//retval').inner_html,
      :retdesc => doc.at('//retdesc').inner_html
    }
  end

  def result_debt_credits_list(doc)

  end

  def result_debt_credit_details(doc)

  end

  def result_user_mail(doc)
    {
      name: doc.at('//useremaillist/useremail')['Name'].encode('UTF-8', 'CP1251'),
      country: doc.at('//useremaillist/useremail')['Country'].encode('UTF-8', 'CP1251')
    }
  end

  def result_create_contract(doc)
  end

  def result_events_token(doc)
    doc['accessToken']

  end

  def result_events_create_post(doc)
    doc['id']
  end

  def result_events_create_comment(doc)
    doc['id']
  end

end



  # def result_operation_history(doc)
  #   operations = []
  #   doc.at('//operations').children.each do |operation|
  #       operations_hash = {}
  #       operation.attributes.each do |attr|
  #         operations_hash[attr[1].name.to_sym] = attr[1].value
  #       end
  #       operation.children.each do |child|
  #           operations_hash[child.name.to_sym] = child.content
  #       end
  #       operations << operations_hash unless operations_hash.empty?
  #   end
  #   {
  #       :operations => operations,
  #       :retval => doc.at('//retval').inner_html.to_i
  #   }
  # end