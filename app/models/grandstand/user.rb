class Grandstand::User < ActiveRecord::Base
  set_table_name :grandstand_users

  attr_accessor :password
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation

  before_save :encrypt_password

  default_scope :order => [:first_name, :last_name]

  has_many :galleries
  has_many :images
  has_many :posts

  validates_confirmation_of :password, :allow_nil => true
  validates_presence_of :email
  validates_uniqueness_of :email, :allow_nil => true

  class << self
    def authenticates_with(credentials)
      password = credentials.delete(:password)
      first(:conditions => credentials)
    end
  end

  # Check whether or not a given password hashes out to this models'
  # stored password.
  def authenticates_with?(check_password)
    encrypted_password == password_digest(check_password)
  end

  # Provides a mailto: formatted link to this users' e-mail address
  def mailto
    "mailto:#{email}"
  end

  # Creates a whitespace-cleaned combination of this users' first and
  # last names
  def name
    return @name if @name
    name = [first_name, last_name].reject(&:blank?).join(' ')
    @name = name.blank? ? email : name
  end

  protected
  # Store a models' salt and password fields. Salting ensures that
  # identical passwords do not appear the same in the database. So
  # if two people have "foobar" as their password, they'll be completely
  # different. Helps prevent rainbow-style attackyness.
  def encrypt_password
    unless password.blank?
      self.salt = Digest::SHA1.hexdigest([Time.now.to_s, (1..10).map{ rand.to_s }].join('--'))
      self.encrypted_password = password_digest(password)
    end
  end

  # Returns a hash of a given password string. Used both for storing
  # passwords and authenticating later. The digest_stretches method
  # ensures passwords are hashed more than once - which prevents brute-
  # force attacks from being even remotely efficient. Take that, hacker
  # dickheads.
  def password_digest(password)
    password_digest = Grandstand.site_key
    # Perform stretching per RESTful Authentication's guidelines
    Grandstand.digest_stretches.times do
      password_digest = Digest::SHA1.hexdigest([password_digest, salt, password, Grandstand.site_key].join('--'))
    end
    password_digest
  end
end
