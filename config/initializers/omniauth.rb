# frozen_string_literal: true

# https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284
# NOTE: If didn't redirect directly, don't enable GET
OmniAuth.config.allowed_request_methods = %i[post get]
