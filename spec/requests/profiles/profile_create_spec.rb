require 'rails_helper'

RSpec.describe "profile api", :type => :request do
  describe "creating a profile" do
    before(:each) do
      create(:user)
    end

    def profile_hash(title=nil, replace_data=nil)
      return_hash = {
        first_name: "Test",
        last_name: "Last",
        profession: "Web Developer",
        tech_of_choice: "JavaScript",
        years_experience: 2,
        willing_to_manage: true
      }

      return_hash[title] = "" if title && !replace_data

      return_hash[title] = replace_data if title && replace_data

      return_hash
    end

    def post_to_profile(user, token, data_hash)
      post "/users/#{user.id}/profile", 
        { 
          profile: {
            first_name: data_hash[:first_name], 
            last_name: data_hash[:last_name], 
            profession: data_hash[:profession], 
            tech_of_choice: data_hash[:tech_of_choice], 
            years_experience: data_hash[:years_experience], 
            willing_to_manage: data_hash[:willing_to_manage]
          }
        }, {'Authorization': token}
    end

    def parse_profile(profile)
      formatted_json = {
                         first_name: profile.first_name,
                         last_name: profile.last_name,
                         profession: profile.profession,
                         tech_of_choice: profile.tech_of_choice,
                         years_experience: profile.years_experience,
                         willing_to_manage: profile.willing_to_manage
                       }
    end

    def confirm_profile_not_saved(user)
      expect(Profile.find_by(user_id: user.id)).to be_nil
    end

    it "returns user and profile info with POST to /users/:user_id/profile" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash)

      expect(response_as_json[:user][:profile]).to eq(profile_hash)
    end

    it "saves profile to database with POST to /users/:user_id/profile" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash)

      profile = Profile.find_by(user_id: response_as_json[:user][:id])

      expect(parse_profile(profile)).to eq(response_as_json[:user][:profile])
    end

    it "returns an error with invalid POST to /users/:user_id/profile - no first name" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash(:first_name))

      expect(response_as_json[:errors][0]).to eq("First name can't be blank")

      confirm_profile_not_saved(user)
    end
    
    it "returns an error with invalid POST to /users/:user_id/profile - no last name" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash(:last_name))

      expect(response_as_json[:errors][0]).to eq("Last name can't be blank")

      confirm_profile_not_saved(user)
    end

    it "returns an error with invalid POST to /users/:user_id/profile - no profession" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash(:profession))

      expect(response_as_json[:errors][0]).to eq("Profession can't be blank")

      confirm_profile_not_saved(user)
    end

    it "returns an error with invalid POST to /users/:user_id/profile - no tech of choice" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash(:tech_of_choice))

      expect(response_as_json[:errors][0]).to eq("Tech of choice can't be blank")

      confirm_profile_not_saved(user)
    end

    it "returns an error with invalid POST to /users/:user_id/profile - no years experience" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash(:years_experience))

      expect(response_as_json[:errors][0]).to eq("Years experience can't be blank")

      confirm_profile_not_saved(user)
    end

    it "returns an error with invalid POST to /users/:user_id/profile - no willing to manage" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash(:willing_to_manage))

      expect(response_as_json[:errors][0]).to eq("Willing to manage must be true or false")

      confirm_profile_not_saved(user)
    end

    it "returns an error with mismatched datatype POST to /users/:user_id/profile - years experience not a number" do
      user = User.first

      token = user_token(user)

      post_to_profile(user, token, profile_hash(:years_experience, "foo"))

      expect(response_as_json[:errors][0]).to eq("Years experience is not a number")

      confirm_profile_not_saved(user)
    end
  end
end
