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

from xmllib import XMLParser

# daily chump v 1.0

# $Id: EntityEncoder.py,v 1.3 2001/03/16 00:52:04 edmundd Exp $

class EntityEncoder:
    def __init__(self):
        # create reversed entity list
        self.rdefs={}
        for x in XMLParser.entitydefs.keys():
            v=XMLParser.entitydefs[x]
            self.rdefs[int(v[2:-1])]="&"+x+";"

    def encode_chars(self, s):
        out=""
        for c in s:
            o=ord(c)
            if (o>127):
                out=out+"&#"+str(o)+";"
            elif (o<32):
                out=out
                # strip them out!
            elif self.rdefs.has_key(o):
                out=out+self.rdefs[o]
            else:
                out=out+c
        return out

if __name__ == '__main__':
    e=EntityEncoder()
    s=e.encode_chars("'< run \"me\" > raggéd & dïe'")
    if s != "&apos;&lt; run &quot;me&quot; &gt; ragg&#233;d &amp; d&#239;e&apos;":
        print "Test failed."
    else:
        print "Tested OK."
