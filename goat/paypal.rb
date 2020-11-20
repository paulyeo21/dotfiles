#!/usr/bin/env ruby

payment_hash = {
  intent: "sale",
  payer: {
    payment_method: "paypal"
  },
  redirect_urls: {
    return_url: "http://localhost:3000/payment/execute",
    cancel_url: "http://localhost:3000"
  },
  transactions: [
    {
      amount: {
        total: "5",
        currency: "USD"
      },
      description: "Testing for refunds with a chargeback"
    }
  ]
}

p = PayPal::SDK::REST::DataTypes::Payment.new(payment_hash)
p.create
p.id
p.error

p.execute(payer_id: )
p.error
