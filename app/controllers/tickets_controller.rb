class TicketsController < ApplicationController
  before_action :set_programmation, only: [ :new, :create ]
  before_action :set_ticket, only: [ :show, :success, :cancel ]

  def new
    @ticket = Ticket.new(programmation: @programmation)
  end

  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.programmation = @programmation
    @ticket.status = :pending

    if @ticket.save
      session = Stripe::Checkout::Session.create(
        payment_method_types: [ "card" ],
        line_items: [ {
          price_data: {
            currency: "eur",
            product_data: {
              name: "#{@programmation.movie.title} - #{@ticket.ticket_type_name}",
              description: "Séance du #{I18n.l(@programmation.time, format: :long)}"
            },
            unit_amount: (@ticket.price * 100).to_i
          },
          quantity: @ticket.quantity
        } ],
        mode: "payment",
        success_url: success_ticket_url(@ticket),
        cancel_url: cancel_ticket_url(@ticket),
        customer_email: @ticket.email,
        metadata: {
          ticket_id: @ticket.id
        }
      )

      @ticket.update(stripe_session_id: session.id)
      redirect_to session.url, allow_other_host: true
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def success
    @ticket.update(status: :paid)
  end

  def cancel
    @ticket.update(status: :cancelled)
  end

  private

  def set_programmation
    @programmation = Programmation.find(params[:programmation_id])
  end

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:ticket_type, :quantity, :email, :name)
  end
end
