module cantera_funcs

  use cantera_xml
  use cantera_thermo
  use cantera_kinetics
  use cantera_transport

  contains

    type(phase_t) function ctfunc_importPhase(src, id, loglevel)
      implicit none
      character*(*), intent(in) :: src
      character*(*), intent(in), optional :: id
      integer, intent(in), optional :: loglevel

      character(20) :: model
      type(XML_Node) root, s, str
      type(phase_t) self

      root = new_XML_Node(src = src)
      if (present(id)) then
         s = ctxml_child(root, id = id)
      else
         s = ctxml_child(root, 'phase')
      end if
      
      self = newThermoPhase(s)
      call newKinetics(s, self)

      str = ctxml_child(s, 'transport')
      call ctxml_getAttrib(str, 'model', model)
      if (present(loglevel)) then
         write(*,*) 'tr 1'
         self%tran_id = newTransport(model, self%thermo_id, loglevel)
      else
         write(*,*) 'tr 2'
         self%tran_id = newTransport(model, self%thermo_id, 0)
      end if

      ctfunc_importPhase = self
      return
    end function ctfunc_importphase

    subroutine ctfunc_phase_report(self, buf, show_thermo)
      implicit none
      type(phase_t), intent(inout) :: self
      character*(*), intent(out) :: buf
      integer, intent(in), optional :: show_thermo
      if (present(show_thermo)) then
         self%err = ctphase_report(self%thermo_id, buf, show_thermo)
      else
         self%err = ctphase_report(self%thermo_id, buf, 0)
      end if
    end subroutine ctfunc_phase_report

    subroutine ctfunc_getCanteraError(buf)
      implicit none
      integer :: ierr
      character*(*), intent(out) :: buf
      ierr = ctgetCanteraError(buf)
    end subroutine ctfunc_getCanteraError

    subroutine ctfunc_addCanteraDirectory(self, buf)
      implicit none
      type(phase_t), intent(inout) :: self
      character*(*), intent(in) :: buf
      self%err = ctaddCanteraDirectory(self%thermo_id, buf)
    end subroutine ctfunc_addCanteraDirectory

end module cantera_funcs
