require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
    test "full title helper" do
        assert_equal "Gimbarr", full_title
        assert_equal "Help | Gimbarr", full_title("Help")
    end
end