module Webmoney

  # Presets for interfaces
  def interface_urls
    {
      :create_invoice     => { :url => 'XMLInvoice.asp' },       # x1
      :create_transaction => { :url => 'XMLTrans.asp' },         # x2
      :operation_history  => { :url => 'XMLOperations.asp' },    # x3
      :outgoing_invoices  => { :url => 'XMLOutInvoices.asp' },   # x4
      :finish_protect     => { :url => 'XMLFinishProtect.asp' }, # x5
      :send_message       => { :url => 'XMLSendMsg.asp' },       # x6
      :check_sign         => { :url => 'XMLClassicAuth.asp' },   # x7
      :find_wm            => { :url => 'XMLFindWMPurse.asp' },   # x8
      :balance            => { :url => 'XMLPurses.asp' },        # x9
      :incoming_invoices  => { :url => 'XMLInInvoices.asp' },    # x10
      :get_passport       => { :url => 'https://apipassport.webmoney.ru/asp/XMLGetWMPassport.asp' , # x11
                               :x509 => lambda {|url| url.sub(/\.asp$/, 'Cert.asp')} },
      :reject_protection  => { :url => 'XMLRejectProtect.asp' }, # x13
      :transaction_moneyback => { :url => 'XMLTransMoneyback.asp' }, # x14
      :i_trust            => { :url => 'XMLTrustList.asp'  },    # x15
      :trust_me           => { :url => 'XMLTrustList2.asp' },    # x15
      :trust_save         => { :url => 'XMLTrustSave2.asp' },    # x15
      :create_purse       => { :url => 'XMLCreatePurse.asp' },   # x16
      :create_contract    => { :url => 'https://arbitrage.webmoney.ru/xml/X17_CreateContract.aspx', },  # x17
      :get_contract_info  => { :url => 'https://arbitrage.webmoney.ru/xml/X17_GetContractInfo.aspx' },  # x17
      :transaction_get    => { :url => 'https://merchant.webmoney.ru/conf/xml/XMLTransGet.asp' },       # x18
      :check_user         => { :url => 'https://apipassport.webmoney.ru/XMLCheckUser.aspx',             # x19
                               :x509 => lambda {|url| url.sub(/\.aspx$/, 'Cert.aspx')} },
      :bussines_level     => { :url => 'https://bl.wmtransfer.com/levels/XMLWMIDLevel.aspx' },
      :trust_level        => {  url:   'https://debt.wmtransfer.com/xmlTrustLevelsGet.aspx'},
      :login              => { :url => 'https://login.wmtransfer.com/ws/authorize.xiface' },            # login
      :req_payment        => { :url => 'https://merchant.webmoney.ru/conf/xml/XMLTransRequest.asp'},    # x20
      :conf_payment       => { :url => 'https://merchant.webmoney.ru/conf/xml/XMLTransConfirm.asp'},    # x20
      :set_trust          => { :url => 'https://merchant.webmoney.ru/conf/xml/XMLTrustRequest.asp'},    # x21
      :confirm_trust      => { :url => 'https://merchant.webmoney.ru/conf/xml/XMLTrustConfirm.asp'},    # x21
      :merchant_token     => { :url => 'https://merchant.webmoney.ru/conf/xml/XMLTransSave.asp'},       # x22
      :cancel_invoice     => { url: 'XMLInvoiceRefusal.asp'},       # x23
      get_country:          { url: 'https://passport.webmoney.ru/asp/XMLGetCountryId.asp'},
      user_mail:            { url: 'XMLGetUsersEmailList2.asp'},
# CREDIT API
      :credit_list        => { :url => 'https://credit.webmoney.ru/CTenders.ashx', method: :get}, # tenders list or single tender
      :credit_bid         => { :url => 'https://credit.webmoney.ru/ZTenderNew.ashx', method: :get}, #
      :credit_bids_list   => { :url => 'https://credit.webmoney.ru/ZTenders.ashx', method: :get},
      :credit_bid_del     => { :url => 'https://credit.webmoney.ru/ZTenderDel.ashx', method: :get},
      :credit_borrower_tenders   => { :url => 'https://credit.webmoney.ru/BorrowerTenders.ashx', method: :get },
# DEBT API
      debt_new_line:                     { url: 'https://debt.wmtransfer.com/api/creditlinenew.aspx'},
      debt_block_user:                   { url: 'https://debt.wmtransfer.com/api/creditblock.aspx'},
      debt_return_loan:                  { url: 'https://debt.wmtransfer.com/api/creditreturn.aspx'},
      debt_credits_list:                 { url: 'https://debt.wmtransfer.com/api/credits.aspx' },
      debt_credit_details:               { url: 'https://debt.wmtransfer.com/api/credit.aspx' },
      debt_credit_lines:                 { url: 'https://debt.wmtransfer.com/api/creditlines.aspx'},
# WM.exchanger
      exchanger_current_tenders:         { url: 'https://wm.exchanger.ru/asp/XMLWMList.asp', method: :get},
      exchanger_tender_change_rate:      { url: 'https://wm.exchanger.ru/asp/XMLTransIzm.asp'},
      exchanger_tender_delete:           { url: 'https://wm.exchanger.ru/asp/XMLTransDel.asp'},
      exchanger_tender_place:            { url: 'https://wm.exchanger.ru/asp/XMLTrustPay.asp'},
      exchanger_my_tenders:              { url: 'https://wm.exchanger.ru/asp/XMLWMList2.asp'},
      exchanger_my_counter_tenders:      { url: 'https://wm.exchanger.ru/asp/XMLWMList3.asp'},
      exchanger_my_tender_counters:      { url: 'https://wm.exchanger.ru/asp/XMLWMList3Det.asp'},
      exchanger_tender_devide:           { url: 'https://wm.exchanger.ru/asp/XMLTransDivide.asp'},
      exchanger_wmid_balance:            { url: 'https://wm.exchanger.ru/asp/XMLWMIDBalance.asp'},
      exchanger_tenders_union:           { url: 'https://wm.exchanger.ru/asp/XMLTransUnion.asp'},
# indx
      indx_balance:                      { url: 'https://secure.indx.ru/api/v1/tradejson.asmx?op=Balance'},
#     events
      events_token:                      { url: 'https://events-api.webmoney.ru/Auth/GetEventsTokenBySign', method: :get }

    }
  end

  protected

  def prepare_interface_urls

    # default transform to x509 version for w3s urls
    default_lambda = lambda {|url| url.sub(/\.asp$/, 'Cert.asp') }

    @interfaces = interface_urls.inject({}) do |m,(k,v)|
      url = v[:url]
      unless url.match %r{^https://}
        url = w3s_url + url
        url = default_lambda.call(url) if !classic?
      else
        transform = v[:x509]
        url = transform.call(url) if !classic? && transform && transform.respond_to?(:call)
      end
      m.merge!(k => {url: URI.parse(url), method: v[:method]})
    end

  end

end
