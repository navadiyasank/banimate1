class PopupSetting < ApplicationRecord
  belongs_to :shop
  enum position: {"bottom_right": 1,"bottom_left": 2}
end
