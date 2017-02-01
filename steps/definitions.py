from behave import *
from provision import main

use_step_matcher("re")


@when('file (?P<filename>.*?) is given then the program passes')
def step_impl(context, filename):
    main(filename, True)

use_step_matcher("parse")