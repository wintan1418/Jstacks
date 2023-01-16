class PaymentsController < ApplicationController
    include Stripe
   
    
    # Stripe.api_version = "2022-03-14"
    Stripe.api_key = ''
    def index
      
    end
    
   
    def create

      # Create a new Stripe customer
      create_stripe_customer(current_user, params[:stripeToken])
    
      # Calculate the amount to charge in cents
      amount = 1000 # This is equivalent to $10.00
    
      # Charge the customer's card
      charge = Stripe::Charge.create(
        customer: current_user.stripe_customer_id,
        amount: amount,
        description: 'Initial payment',
        currency: 'usd',
       
      )
    
      # Save the charge ID to the user's record
      current_user.update(stripe_charge_id: charge.id)
    
      # Create a new Payment record on the user
      payment = Payment.new(
        user: current_user,
        amount: amount,
        stripe_charge_id: charge.id
       

      )
      payment.email = current_user.email
    
      if payment.save
        redirect_to success_path(payment_id: payment.id)
      else
        flash[:error] = "There was an error processing your payment"
        redirect_to new_payment_path
      end
    end
  
    def create_stripe_customer(user, token)
      customer = Stripe::Customer.create(
        email: user.email,
        source: token
      )
      user.update(stripe_customer_id: customer.id)
    end
    
  
  
    def new
      @payment = Payment.new
      @checkout_session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: 'Server'
            },
            unit_amount: 1000,
          },
          quantity: 1,
        }],
        success_url: success_url,
        cancel_url: root_url,
        mode: "payment"
      )
    end

   
        def success
            redirect_to payment_path(params[:payment_id]) 
        end
        
   

    def show
        @payment = Payment.find(params[:id])
        @upload = Upload.new
      end
    
  
  
    
      private
    
      def payment_params
        params.require(:payment).permit(:email, :stripe_charge_id)
      end
    end
