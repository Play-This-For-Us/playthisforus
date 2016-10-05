require 'rails_helper'

RSpec.describe EventsController, type: :controller do

  let(:event) { FactoryGirl.create(:event) }

  let(:user) { FactoryGirl.create(:user) }

  let(:valid_attributes) {
    {
      name: "Event 1",
      description: "Event Description",
      user: user
    }
  }

  let(:invalid_attributes) {
    {
      name: ""
    }
  }

  before(:each) do
    sign_in user
  end

  describe "GET #show" do
    it "assigns the requested event as @event" do
      get :show, params: {id: event.to_param}
      expect(assigns(:event)).to eq(event)
    end
  end

  describe "GET #new" do
    it "assigns a new event as @event" do
      get :new, params: {}
      expect(assigns(:event)).to be_a_new(Event)
    end
  end

  describe "GET #edit" do
    it "assigns the requested event as @event" do
      event = Event.create! valid_attributes
      get :edit, params: {id: event.to_param}
      expect(assigns(:event)).to eq(event)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Event" do
        expect {
          post :create, params: {event: valid_attributes}
        }.to change(Event, :count).by(1)
      end

      it "assigns a newly created event as @event" do
        post :create, params: {event: valid_attributes}
        expect(assigns(:event)).to be_a(Event)
        expect(assigns(:event)).to be_persisted
      end

      it "redirects to the created event" do
        post :create, params: {event: valid_attributes}
        expect(response).to redirect_to(Event.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        post :create, params: {event: invalid_attributes}

        expect(assigns(:event)).to be_a_new(Event)
      end

      it "re-renders the 'new' template" do
        post :create, params: {event: invalid_attributes}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "updates the requested event" do
        event = Event.create! valid_attributes
        put :update, params: {id: event.to_param, event: valid_attributes}
        event.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested event as @event" do
        event = Event.create! valid_attributes
        put :update, params: {id: event.to_param, event: valid_attributes}
        expect(assigns(:event)).to eq(event)
      end

      it "redirects to the event" do
        event = Event.create! valid_attributes
        put :update, params: {id: event.to_param, event: valid_attributes}
        expect(response).to redirect_to(event)
      end
    end

    context "with invalid params" do
      it "assigns the event as @event" do
        event = Event.create! valid_attributes
        put :update, params: {id: event.to_param, event: invalid_attributes}
        expect(assigns(:event)).to eq(event)
      end

      it "re-renders the 'edit' template" do
        event = Event.create! valid_attributes
        put :update, params: {id: event.to_param, event: invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested event" do
      event = Event.create! valid_attributes
      expect {
        delete :destroy, params: {id: event.to_param}
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      event = Event.create! valid_attributes
      delete :destroy, params: {id: event.to_param}
      expect(response).to redirect_to(user_path(user))
    end
  end

end
