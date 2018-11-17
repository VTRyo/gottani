class User < ApplicationRecord
    has_many :active_claps, class_name: "Clap", foreign_key: "from_user_id", dependent: :destroy
    has_many :passive_claps, class_name: "Clap", foreign_key: "to_user_id", dependent: :destroy

    has_many :users_of_received_claps_from, through: :passive_claps, source: :from_user
    has_many :users_of_sending_claps_to, through: :active_claps, source: :to_user

    def to_param
        self.nickname
    end

    # 拍手する相手Userを受け取り、Clapレコードを生成するメソッド
    def clap(user)
        Clap.create(from_user_id: self.id, to_user_id: user&.id)
    end

    # 拍手したことをつぶやくためのメソッド
    def tweet(text)
        client = Twitter::REST::Client.new do |config|
            config.customer_key         = ENV['API_KEY']
            config.customer_secret      = ENV['API_SECRET']
            config.access_token         = token
            config.access_token_secret  = secret
        end
        client.update(text)
    end

    # ログイン情報を保持するあためのTokenを生成するクラスメソッド
    def self.new_remember_token
        SecureRandom.urlsafe_base64
    end

    # self.new_remember_tokenを暗号化するためのクラスメソッド
    def self.encrypt(token)
        Diget::SHA256.hexdigest(token.to_s)
    end

    # Twitterログインやユーザ作成を行うためのメソッド。今回はTwitter Oauth認証時のコールバック時に呼び出される
    def self.find_or_create_with_omniauth(auth, remember_token)
        provider = auth['provider']
        uid      = auth['uid']

        user = User.find_or_create_by(provider: provider, uid: uid) do |user|
            user.name       = auth['info']['name']
            user.nickname   = auth['info']['nickname']
            user.image_url  = auth['info']['image']
            user.token      = auth['credentials']['token']
            user.secret     = auth['credentials']['secret']
        end

        user.update!(remember_token: encrypt(remember_token))
    end
    end
end
