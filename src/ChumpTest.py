# Copyright (c) 2001 by Matt Biddulph and Edd Dumbill, Useful Information Company
# All rights reserved.
# 
# License is granted to use or modify this software ("Daily Chump") for
# commercial or non-commercial use provided the copyright of the author is
# preserved in any distributed or derivative work.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESSED OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# $Id: ChumpTest.py,v 1.5 2002/01/29 02:06:05 edmundd Exp $

# Some unit tests for the chump engine.
# Uses the OmPyUnit testing framework available from:
# http://www.objectmentor.com/freeware/downloads.html

from OmPyUnit.UnitTestCase import UnitTestCase
from dailychump import Churn
from dailychump import FileArchiver

class ChumpTest(UnitTestCase):
    def setup(self):
        self.churn = Churn('/tmp')

    def tear_down(self):
        # Optional.  Will be executed after each test method.
        print

    def test_updatetime(self):
        time1 = self.churn.updatetime

        label = self.churn.add_item("http://test.com","mattb")

        time2 = self.churn.updatetime
        self.assert_condition(time1 < time2, "update didn't change time")
        time1 = time2

        self.churn.title_item(label,'testing')

        time2 = self.churn.updatetime
        self.assert_condition(time1 < time2, "update didn't change time")
        time1 = time2

        self.churn.comment_item(label,'testing','testuser')

        time2 = self.churn.updatetime
        self.assert_condition(time1 < time2, "update didn't change time")
        time1 = time2

    def test_get_set_entry(self):
        self.assert_condition(self.churn.get_entry('A') == None,'tried to get non-existant entry and got something back')

    def test_get_set_entry(self):
        label = self.churn.add_item("http://test.com","mattb")
        self.assert_condition(self.churn.get_entry(label) != None)
        self.assert_equals("http://test.com",self.churn.get_entry(label).item)

    def test_labels(self):
        self.assert_equals('A',self.churn.get_next_label())
        for x in range(1,25):
            self.churn.get_next_label()
        self.assert_equals('Z',self.churn.get_next_label())
        for x in range(1,28):
            self.churn.get_next_label()
        self.assert_equals('BB',self.churn.get_next_label())

    def test_view(self):
        self.assert_equals('Label A not found.',self.churn.view_item('A'))
        label = self.churn.add_item("http://test.com","mattb")
        self.assert_equals('A: http://test.com',self.churn.view_item(label))
        self.churn.title_item(label,'testing')
        self.assert_equals('A: testing (http://test.com)',self.churn.view_item(label))

    def test_view_recent(self):
        label = self.churn.add_item("http://test.com","mattb")
        self.churn.title_item(label,'testing')
        self.assert_equals('A: testing (http://test.com)\n',self.churn.view_recent_items(3))
        label = self.churn.add_item("http://test2.com","mattb")
        label = self.churn.add_item("http://test3.com","mattb")
        self.assert_equals('A: testing (http://test.com)\nB: http://test2.com\nC: http://test3.com\n',self.churn.view_recent_items())

from OmPyUnit import TestRunner
TestRunner.run('ChumpTest')
