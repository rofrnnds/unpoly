module Unpoly
  module Rails
    ##
    # This object allows the server to inspect the current request
    # for Unpoly-related concerns such as "is this a page fragment update?".
    #
    # Available through the `#up` method in all controllers, helpers and views.
    class Inspector

      def initialize(controller)
        @controller = controller
      end

      ##
      # Returns whether the current request is an
      # [page fragment update](https://unpoly.com/up.replace) triggered by an
      # Unpoly frontend.
      def up?
        target.present?
      end

      alias_method :unpoly?, :up?

      ##
      # If the current request is a [fragment update](https://unpoly.com/up.replace),
      # this returns the CSS selector of the page fragment that should be updated.
      #
      # The Unpoly frontend will expect an HTML response containing an element
      # that matches this selector. If no such element is found, an error is shown
      # to the user.
      #
      # Server-side code is free to optimize its response by only returning HTML
      # that matches this selector.
      def target
        request.headers['X-Up-Target']
      end

      ##
      # Tests whether the given CSS selector is targeted by the current fragment update.
      #
      # Note that the matching logic is very simplistic and does not actually know
      # how your page layout is structured. It will return `true` if
      # the tested selector and the requested CSS selector matches exactly, or if the
      # requested selector is `body` or `html`.
      #
      # Always returns `true` if the current request is not an Unpoly fragment update.
      def target?(tested_target)
        if up?
          actual_target = target
          if actual_target == tested_target
            true
          elsif actual_target == 'html'
            true
          elsif actual_target == 'body'
            not ['head', 'title', 'meta'].include?(tested_target)
          else
            false
          end
        else
          true
        end
      end

      ##
      # Returns whether the current form submission should be
      # [validated](https://unpoly.com/up-validate) (and not be saved to the database).
      def validate?
        validate_name.present?
      end

      ##
      # If the current form submission is a [validation](https://unpoly.com/up-validate),
      # this returns the name attribute of the form field that has triggered
      # the validation.
      def validate_name
        request.headers['X-Up-Validate']
      end

      ##
      # Forces Unpoly to use the given string as the document title when processing
      # this response.
      #
      # This is useful when you skip rendering the `<head>` in an Unpoly request.
      def title=(new_title)
        response.headers['X-Up-Title'] = new_title
      end

      private

      def request
        @controller.request
      end

      def params
        @controller.params
      end

      def response
        @controller.response
      end

    end
  end
end
