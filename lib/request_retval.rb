#encoding: utf-8
module Webmoney::RequestRetval    # :nodoc:all

  def retval_common(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//retdesc') ? doc.at('//retdesc').inner_html : ''
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_get_passport(doc)
    # retval is attribute <response>
    @error = doc.at('//response')['retval'].to_i
    @errormsg = doc.at('//response')['retdesc']
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
    raise Webmoney::NonExistentWmidError unless doc.at('/response/certinfo/attestat')
  end

  def retval_find_wm(doc)
    # do nothing
    # retval = { 1 - found; 0 - not found }
  end

  def retval_create_invoice(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_outgoing_invoices(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_login(doc)
    if retval = doc.at('/response')['retval']
      @error = retval.to_i
      @errormsg = doc.at('/response')['sval']
    else
      @error = -3
      @errormsg = 'Unknown response'
    end
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_transaction_get(doc)
    # do nothing
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    @gooderrors = [0, 8, 9, 10, 11, 12]
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @gooderrors.include?(@error)
  end

  def retval_check_user(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//retdesc') ? doc.at('//retdesc').inner_html : ''
    not_exception_result_errors = [0, 404]
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless not_exception_result_errors.include?(@error)
  end

  def retval_balance(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//retdesc') ? doc.at('//retdesc').inner_html : ''
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_req_payment(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @techerrordesc = doc.at('//retdesc').inner_html
    @errormsg = doc.at('//userdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join('-') unless @error == 0
  end

  def retval_conf_payment(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//userdesc').inner_html
    @techerrordesc = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join('-') unless @error == 0
  end

  def retval_operation_history(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_set_trust(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//userdesc').inner_html
    @techerrordesc = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join('-') unless @error == 0
  end

  def retval_operation_history(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_merchant_token(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_transaction_moneyback(doc)
    retval_element = doc.at('//retval')
    @error = retval_element.inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_credit_list(doc)
    @error = doc.at('//retval').inner_html.to_i
    raise Webmoney::ResultError, @error unless @error == 0
  end

  def retval_credit_bid(doc)
    @error = doc.at('//retval').inner_html.to_i
    @amount = doc.at('//nearestamount').inner_html.to_f if doc.at('//nearestamount')
    raise Webmoney::UnknownTender, @error if @error == 30002
    raise Webmoney::CreditAmountError, [@error, @amount].join(' ') if @error == 30111
    raise Webmoney::TooMuchAmount, @error if @error == 110
    raise Webmoney::ResultError, @error unless @error == 0
  end

  def retval_credit_bids_list(doc)
    @error = doc.at('//retval').inner_html.to_i
    raise Webmoney::ResultError, @error unless @error == 0
  end

  def retval_credit_bid_del(doc)
    @error = doc.at('//retval').inner_html.to_i
    raise Webmoney::ResultError, @error unless @error == 0
  end

  def retval_credit_borrower_tenders(doc)
    @error = doc.at('//retval').inner_html.to_i
    raise Webmoney::ResultError, @error unless @error == 0
  end

  def retval_exchanger_tender_place(doc)
#    retval_element = doc.at('//retval')
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_exchanger_tender_change_rate(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ExchangeRateError, [@error, @errormsg].join(' ') if @error == 7
    raise Webmoney::ExchangeRateToFastError, [@error, @errormsg].join(' ') if @error == 9
    raise Webmoney::RateNotChangedError, [@error, @errormsg].join(' ') if @error == 5
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless [0, 5, 7, 9].include? @error

  end

  def retval_exchanger_my_tenders(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_exchanger_my_counter_tenders(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_exchanger_current_tenders(doc)
    raise Webmoney::ResultError if doc.at( '//BankRate')['ratetype'].empty? || doc.at( '//BankRate')['direction'].empty?
  end

  def retval_exchanger_tender_devide(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_exchanger_tenders_union(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_exchanger_my_tender_counters(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_exchanger_wmid_balance(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_indx_balance(doc)

  end

  def retval_debt_block_user(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_debt_credit_lines(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_debt_return_loan(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_debt_credits_list(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_debt_credit_details(doc)
    @error = doc.at('//retval').inner_html.to_i
    @errormsg = doc.at('//retdesc').inner_html
    raise Webmoney::ResultError, [@error, @errormsg].join(' ') unless @error == 0
  end

  def retval_files_get_session(doc)

  end

  def retval_files_auth(doc)

  end
end
