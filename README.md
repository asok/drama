# Drama

Create Acts which are [service](http://adamniedzielski.github.io/blog/2014/11/25/my-take-on-services-in-rails/) like objects that create a fourth layer between controllers and models in Rails applications.

## Rationale

The classical controller in Rails does a lot of things. Namely:

* assigns variables
* renders a template or redirects, sometimes sets up flash messages
* whitelists parameters
* finally does some domain logic - interacts with db and/or API's, sends mail etc.

It's a lot of responsability. Unit testing everything in a single spec file tends to be difficult.
Here's an example:

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(params.require(:user).permit(:email, :password))
    if @user.save
      UserMailer.created(@user).deliver_now
      redirect_to users_path, notice: 'Success'
    else
      flash[:alert] = 'Failure'
      render :new
    end
  end
end

RSpec.describe UsersController do
  describe '#create' do
    before do
      allow(User).to receive(new){ user }
      allow(user).to receive(:save){ result }

      post :create, user: {email: 'user@example.com', pass: 'pass' }
    end
    let(:user) { User.new }

    context 'success' do
      let(:result) { true }

      it 'redirects to index' do
        expect(response).to be_redirect_to(users_path)
      end

      it 'sets up the flash message' do
        expect(flash[:notice]).to eq('Success')
      end

      it 'sets up user' do
        expect(User).to have_received(:new).with(email: 'user@example.com', password: 'pass')
      end

      it 'saves the user' do
        expect(user).to have_received(:save)
      end

      it 'sends the mail' do
        expect(UserMailer.deliveries).to_not be_empty
      end
    end

    context 'failure' do
      let(:result) { false }

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end

      it 'assigns the object' do
        expect(assigns(:user)).to eq(user)
      end

      it 'sets up the flash message' do
        expect(flash[:notice]).to eq('Failure')
      end

      it 'does not send the mail' do
        expect(UserMailer.deliveries).to be_empty
      end
    end
  end
end
```

What if half of those responsabilities where to be offloaded to some other object?
This way in the controller's tests we only have to unit test variable assignment and the rendering.
Whitelisting and domain logic we can test in a different place.

```ruby
class UsersController < ApplicationController
  acts_on :create

  def create
    if act.call
      redirect_to users_path, notice: 'Success'
    else
      @user = act.user
      flash[:alert] = 'Failure'
      render :new
    end
  end
end

RSpec.describe UsersController do
  it{ should act_on(:create).with(CreateUserAct) }

  describe '#create' do
    before do
      allow(controller).to receive(:act){ act }

      post :create, user: {email: 'user@example.com', pass: 'pass'}
    end
    let(:act) { instance_spy('act', call: result) }

    it 'calls the service' do
      expect(act).to have_received(:call).with(email: 'user@example.com', pass: 'pass')
    end

    context 'success' do
      let(:result) { true }

      it 'redirects to index' do
        expect(response).to be_redirect_to(users_path)
      end

      it 'sets up the flash message' do
        expect(flash[:notice]).to eq('Success')
      end
    end

    context 'failure' do
      let(:result) { false }

      it 'renders the new template' do
        expect(response).to render_template(:new)
      end

      it 'sets up the flash message' do
        expect(flash[:notice]).to eq('Failure')
      end

      it 'assigns the object' do
        expect(assigns(:user)).to eq(user)
      end
    end
  end
end

RSpec.describe CreateUserAct do
  # test the whitelisting, db interaction and sending mail here
end
```

The benefits of offloading the heavy work from controllers are apparent when we start doing more things on the user creation.
Maybe later we will want to schedule some Sidekq job or add the created user to some listing of subscribers. And don't forget about the error handling.

The controller should only handle the parameteres coming from a browser and setting up a response. It shouldn't care how to send a mail or schedule a job.

Piling everything onto the model layer is not a solution neither. Once your application begins to grow having big models will be a burden also. Having a lot of responsabilities in one place means it is hard to comprehend, mantain and to test.

## Installation



Add this line to your application's Gemfile:

```ruby
gem 'drama', github: 'asok/drama'
```

And then execute:

    $ bundle

## Usage

### Act layer

Create an Act that derives from `Drama::Act` that will be used in your controller's action. The Act has to respond to `call` method.

```ruby
class CreateUserAct < Drama::Act
  def call
    User.create!(user_params)
  end

  protected

  def user_params
    controller.params.require(:user).permit(:email, :password)
  end
end
```

You can use `require_params` method to generate `user_params` in the Act.

```ruby
class CreateUserAct < Drama::Act
  require_params(:user).permit(:email, :password)

  def call
    User.create!(user_params)
  end
end
```


### Controller layer

Call `acts_on` method in your controller so the method `act` is available in your actions.
The `act` method returns an instance of Act that is designated to a given action. The Act object is instantiated with the controller.
Withing the Act's code you can access the controller via `controller` method.

```ruby
class UsersController < ApplicationController
  acts_on create: CreateUserAct

  def create
    act.call
  end
end
```

Also method `act!` is available which does the same as `act.call`.

```ruby
class UsersController < ApplicationController
  acts_on create: CreateUserAct

  def create
    act!
  end
end
```

If the name of the Act can be derived from the controller's and action's name you can omit the constant name in the call to `acts_on`.
The naming convention is "#{action's name}#{controller's name in singular form}#{Act}". Camel case of course.

```ruby
class UsersController < ApplicationController
  acts_on :create # will designate CreateUserAct to the :create action

  def create
    act!
  end
end
```

### Testing

#### RSpec

#### act, act! example methods

Similar to the controller you can call `act` and `act!` methods to call the acts. You can create a fake controller via `controller` method like [anonymous controller in rspec-rails](https://www.relishapp.com/rspec/rspec-rails/docs/controller-specs/anonymous-controller):

```ruby
class Act < Drama::Act
  def call(email)
    controller.user.email = email
  end
end

describe Act do
  let(:user){ Struct.new(:email).new }

  controller do
    def current_user
      user
    end
  end

  it 'sets up email on the user' do
    act!('foo@example.com')
    expect(user.email).to eq('foo@example.com')
  end
end

```

#### act_on matcher

It tests that a correct acts are designated to the correct actions.

```ruby
  class UsersController
    acts_on :create, index: FetchingUsersAct
  end

  RSpec.describe UsersController do
    it{ should act_on(:create).with(FetchingUsersAct) }
  end
```

#### require_params matcher

It tests that a correct params are being required and permitted.

```ruby
  class CreateUserAct < Drama::Act
    require_params(:user).permit(:email, :password)
  end

  RSpec.describe CreateUserAct do
    it{ should require_params(:user).and_permit(:email, :password) }
  end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/asok/drama.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

