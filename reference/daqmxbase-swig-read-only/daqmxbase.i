// $Id: daqmxbase.i 89 2008-04-08 20:09:05Z bikenomad $
// SWIG (http://www.swig.org) definitions for
// National Instruments NI-DAQmx Base

// ruby-daqmxbase: A SWIG interface for Ruby and the NI-DAQmx Base data
// acquisition library.
// 
// Copyright (C) 2007 Ned Konz
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License.  You may obtain a copy
// of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//

// Will be Ruby module named Daqmxbase
%module(docstring="A SWIG interface for Ruby and the NI-DAQmx Base data acquisition library") daqmxbase

%include "typemaps.i"
%include "exception.i"
%include "carrays.i"
%include "cdata.i"

%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ruby.h"

// patch typo in v2.20f header file
#define  DAQmxReadBinaryI32  DAQmxBaseReadBinaryI32
#include "NIDAQmxBase.h"

static VALUE dmxError = Qnil;   // Daqmxbase::Error
static VALUE dmxWarning = Qnil; // Daqmxbase::Warning

static void handle_DAQmx_error(int32 errCode)
{
  size_t errorBufferSize, prefixSize;
  char *errorBuffer, *prefixEnd;
  VALUE exc;

  if (errCode == 0)
    return;

  errorBufferSize = (size_t)DAQmxBaseGetExtendedErrorInfo(NULL, 0);
  errorBufferSize += 30; // add room for prefix (10+length of %ld)
  errorBuffer = malloc(errorBufferSize);
  snprintf(errorBuffer, errorBufferSize,
    ((errCode < 0) ? "Error %ld: " : "Warning %ld:"), errCode);
  prefixSize = strlen(errorBuffer);
  prefixEnd = errorBuffer + prefixSize;

  DAQmxBaseGetExtendedErrorInfo(prefixEnd, (uInt32)(errorBufferSize - prefixSize));
  exc = rb_exc_new2(((errCode < 0) ? dmxError : dmxWarning), errorBuffer);
  rb_iv_set(exc, "@code", LONG2FIX(errCode));

  free(errorBuffer);
  rb_exc_raise(exc);
}

static VALUE dmxErrorCode(VALUE self)
{
    return rb_iv_get(self, "@code");
}

%};

%init %{
  // initialize exceptions
  if (dmxError == Qnil)
  {
    dmxError = rb_define_class_under(mDaqmxbase, "Error", rb_eRuntimeError);
    rb_define_method(dmxError, "code", dmxErrorCode, 0);
  }

  if (dmxWarning == Qnil)
  {
    dmxWarning = rb_define_class_under(mDaqmxbase, "Warning", rb_eRuntimeError);
    rb_define_method(dmxWarning, "code", dmxErrorCode, 0);
  }
%};

// patch typo in header file
#define  DAQmxReadBinaryI32  DAQmxBaseReadBinaryI32

%apply  unsigned long *OUTPUT { bool32 *isTaskDone, int32 *sampsPerChanRead,
  int32 *sampsPerChanWritten, uInt32 *value, uInt32 *data };
%apply  char *OUTPUT { char errorString[] };
%apply  float *OUTPUT { float64 *value };

// Note that TaskHandle is typedef'd as uInt32*
// so here &someTask is equivalent to a TaskHandle.
%inline %{
  typedef struct { uInt32 t; } Task;
%};


%extend Task {
  %ignore t;

  // Allow passing Ruby array or just single (float or fix) number
  %typemap(in) float64 writeArray[],
               uInt8 writeArray[],
               uInt32 writeArray[]
  {
    // *** BEGIN typemap(in) (<T> writeArray[])
    long len = 1;
    long i;
    $1 = calloc(len, sizeof($1_basetype));

    switch (rb_type($input))
    {
      case T_ARRAY:
        len = RARRAY($input)->len;
        $1 = realloc($1, sizeof($1_basetype)*(size_t)len);
        for (i = 0; i < len; i++)
        {
          $1_basetype val;
          VALUE v;
          v = rb_ary_entry($input, i);
          switch (rb_type(v))
          {
            case T_FIXNUM:
              val = ($1_basetype)NUM2LONG(v);
              break;

            case T_BIGNUM:
              val = ($1_basetype)NUM2ULONG(v);
              break;

            case T_FLOAT:
              val = ($1_basetype)RFLOAT(v)->value;
              break;

            default:
              goto Error;
          };
          $1[i] = val;
        }
        break;

      case T_FIXNUM:
        $1[0] = ($1_basetype)NUM2LONG($input);
        break;

      case T_BIGNUM:
        $1[0] = ($1_basetype)NUM2ULONG($input);
        break;

      case T_FLOAT:
        $1[0] = ($1_basetype)RFLOAT($input)->value;
        break;

  Error:
      default:
        free($1);
        $1 = NULL;
        rb_raise(rb_eTypeError, "writeArray must be FIXNUM, float, or array of float or fixnum");
        break;
    };
    // *** END typemap(in) (<T> writeArray[])
  };

  // free array allocated by above
  %typemap(freearg) (float64 writeArray[]) {
    // *** typemap(freearg) (float64 writeArray[])
    if ($1) free($1);
  };

  // ruby size param in: alloc array of given size
  %typemap(in) (float64 readArray[], uInt32 arraySizeInSamps),
               (uInt8 readArray[], uInt32 arraySizeInSamps),
               (uInt16 readArray[], uInt32 arraySizeInSamps),
               (uInt32 readArray[], uInt32 arraySizeInSamps) {
    // *** BEGIN typemap(in) (<T> readArray[], uInt32 arraySizeInSamps)
    long len;

    if (FIXNUM_P($input))
      len = FIX2LONG($input);
    else
      rb_raise(rb_eTypeError, "readArray size must be FIXNUM");

    if (len <= 0)
      rb_raise(rb_eRangeError, "readArray size must be > 0 (but got %ld)", len);

    $1 = calloc((size_t)len, sizeof($1_basetype));
    $2 = (uInt32)len;
    // *** END typemap(in) (<T> readArray[], uInt32 arraySizeInSamps)
  };

  // free array allocated by above
  %typemap(freearg) (float64 readArray[], uInt32 arraySizeInSamps),
               (uInt8 readArray[], uInt32 arraySizeInSamps),
               (uInt16 readArray[], uInt32 arraySizeInSamps),
               (uInt32 readArray[], uInt32 arraySizeInSamps) {
    // *** typemap(freearg) (float64 readArray[], uInt32 arraySizeInSamps)
    if ($1) free($1);
  };

  // make Ruby Array of FIXNUMs
  %typemap(argout) (uInt8 readArray[], uInt32 arraySizeInSamps),
                   (uInt16 readArray[], uInt32 arraySizeInSamps),
                   (uInt32 readArray[], uInt32 arraySizeInSamps) {
    // *** BEGIN typemap(argout) (uIntx readArray[], uInt32 arraySizeInSamps)
    long i;
    VALUE data;

    // create Ruby array of given length
    data = rb_ary_new2($2);

    // populate it an element at a time.
    for (i = 0; i < (long)$2; i++)
      rb_ary_store(data, i, ULONG2NUM($1[i]));

    $result = SWIG_Ruby_AppendOutput($result, data);
    // *** END typemap(argout) (uIntx readArray[], uInt32 arraySizeInSamps)
  };

  // make Ruby Array of floats
  %typemap(argout) (float64 readArray[], uInt32 arraySizeInSamps) {
    // *** BEGIN typemap(argout) (float64 readArray[], uInt32 arraySizeInSamps)
    long i;
    VALUE data;

    // create Ruby array of given length
    data = rb_ary_new2($2);

    // populate it an element at a time.
    for (i = 0; i < (long)$2; i++)
      rb_ary_store(data, i, rb_float_new($1[i]));

    $result = SWIG_Ruby_AppendOutput($result, data);
    // *** END typemap(argout) (float64 readArray[], uInt32 arraySizeInSamps)
  };

  // pass error code return from DAQmxBase functions to Ruby
  %typemap(out) int32 {
    // *** BEGIN typemap(out) int32
    if ($1) handle_DAQmx_error($1);
    $result = LONG2FIX($1);
    // *** END typemap(out) int32
  };

  // ignore "bool32 *reserved" arguments
  %typemap(in, numinputs=0) bool32 *reserved (bool32 temp) {
    // *** BEGIN typemap(in, numinputs=0) bool32 *reserved (bool32 temp)
    temp = 0;
    $1 = &temp;
    // *** END typemap(in, numinputs=0) bool32 *reserved (bool32 temp)
  };

  // ignore "const char nameToAssignToChannel[]" arguments
  // ignore "const char customScaleName[]" arguments
  %typemap(in, numinputs=0) const char nameToAssignToChannel[],
                            const char nameToAssignToLines[],
                            const char customScaleName[] {
    // *** BEGIN typemap(in, numinputs=0) const char nameToAssignToChannel[]/customScaleName
    $1 = NULL;
    // *** END typemap(in, numinputs=0) const char nameToAssignToChannel[]/customScaleName
  };

  %typemap(in, numinputs=0) int32 lineGrouping {
    // *** BEGIN typemap(in, numinputs=0) int32 lineGrouping
    $1 = DAQmx_Val_ChanForAllLines;
    // *** END typemap(in, numinputs=0) int32 lineGrouping
  };

  %typemap(in, numinputs=0) int32 measMethod {
    // *** BEGIN typemap(in, numinputs=0) int32 measMethod
    $1 = DAQmx_Val_LowFreq1Ctr;
    // *** END typemap(in, numinputs=0) int32 measMethod
  };

  %typemap(in, numinputs=0) float64 measTime {
    // *** BEGIN typemap(in, numinputs=0) int32 measTime
    $1 = 0.0;
    // *** END typemap(in, numinputs=0) int32 measTime
  };

  // if you give a non-empty name, you get LoadTask, else CreateTask.
  Task(const char *taskName = NULL) {
    Task *t = (Task *)calloc(1, sizeof(Task));
    int32 result;
    if (&taskName[0] == NULL || taskName[0] == '\0')
      result = DAQmxBaseCreateTask(taskName, (TaskHandle *)(void *)&t);
    else
      result = DAQmxBaseLoadTask(taskName, (TaskHandle *)(void *)&t);
    if (result) handle_DAQmx_error(result);
    return t;
  }
  ~Task() {
    int32 result = DAQmxBaseStopTask((TaskHandle)(void *)self);
    result = DAQmxBaseClearTask((TaskHandle)(void *)self);
    free(self);
  }
};

%include "daqmxbase_decls.i"
%import "NIDAQmxBase.h"

//  vim: filetype=swig ts=2 sw=2 et ai
