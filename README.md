# OTRS_AuthHeader

A simple authentication module for use with external authentication hardware, such as a single-signon portal. The module accepts a user (or customer user) if a certin HTTP header exists and contains a valid user name. The name of the header is configurable. The module fits into the OTRS authentication stack, so it can be combined with DB authentication or any other authentication methods.

