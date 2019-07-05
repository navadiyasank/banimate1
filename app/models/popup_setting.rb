class PopupSetting < ApplicationRecord
  belongs_to :shop
  enum position: {"center": 1, "right_top": 2,"left_top": 3,"right_bottom": 4,"left_bottom": 5}
end
