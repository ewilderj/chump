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

# $Id: dailychumpcmd.py,v 1.3 2001/03/16 00:52:05 edmundd Exp $

# daily chump v 1.0

## command line interface to the chump engine

from dailychump import DailyChump
from ircbot import SingleServerIRCBot
from irclib import nm_to_n, irc_lower
import string
import sys
from cmd import Cmd
import readline

class DailyChumpCmd(Cmd):
    def __init__(self, directory, user):
        self.chump = DailyChump(directory)
        self.user = user

    def start(self):
        self.prompt = "dc> "
        self.cmdloop("Welcome to the Daily Chump")

    def do_quit(self,cmd):
        sys.exit(0)

    def do_database(self,cmd):
        print self.chump.get_database()

    def default(self,line):
        msg = string.rstrip(line)
        output = self.chump.process_input(self.user,msg)
        if output != None:
            print output

def main():
    import sys
    import getopt
    args = sys.argv[1:]
    optlist, args = getopt.getopt(args,'s:p:c:n:d:')
    port = 6667

    directory = ''

    for o in optlist:
        name = o[0]
        value = o[1]
        if name == '-d':
            directory = value

    if directory != '':
        cmd = DailyChumpCmd(directory,"cmd")
        cmd.start()
    else:
        print "Commandline options:"
        print
        print "  -d directory for XML store"

if __name__ == "__main__":
    main()
