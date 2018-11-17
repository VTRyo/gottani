class User < ApplicationRecord
    has_many :active_claps, class_name: "Clap", foreign_key: "from_user_id", dependent: :destroy
    has_many :passive_claps, class_name: "Clap", foreign_key: "to_user_id", dependent: :destroy

    has_many :users_of_received_claps_from, through: :passive_claps, source: :from_user
    has_many :users_of_sending_claps_to, through: :active_claps, source: :to_user

    def to_param
        self.niclname
    end
end
